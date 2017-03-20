class User < ActiveRecord::Base
  GENDER_TYPES = ["Not telling", "Male", "Female"]
  ACCOUNT_TYPES = ["Student", "Teacher"]
  devise
  paginates_per 1
  # DEVISE
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  #    database_authenticatable – Users will be able to authenticate with a login and password that are stored in the database. (password is stored in a form of a digest).
  #    registerable – Users will be able to register, update, and destroy their profiles.
  #    recoverable – Provides mechanism to reset forgotten passwords.
  #    rememberable – Enables “remember me” functionality that involves cookies.
  #    trackable – Tracks sign in count, timestamps, and IP address.
  #    validatable – Validates e-mail and password (custom validators can be used).
  #    confirmable – Users will have to confirm their e-mails after registration before being allowed to sign in.
  #    lockable – Users’ accounts will be locked out after a number of unsuccessful authentication attempts.
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable, :validatable,
         :lastseenable, :confirmable
          #, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  phony_normalize :phone_number, as: :full_number, default_country_code: :phone_country_code

  has_one :gallery
  has_many :offers, dependent: :destroy
  #before_save -> { skip_confirmation! }
  has_many :sent_comment, :class_name => 'Comment', :foreign_key => 'sender_id'
  has_many :received_comment, :class_name => 'Comment', :foreign_key => 'subject_id'
  has_many :reviews_sent, :class_name => 'Review', :foreign_key => 'sender_id'
  has_many :reviews_received, :class_name => 'Review', :foreign_key => 'subject_id'
  has_many :levels, through: :degrees
  belongs_to :level
  
  has_and_belongs_to_many :bbb_meetings

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :full_number

  after_update :reprocess_avatar, :if => :cropping?
  after_create :create_gallery

  acts_as_messageable
  acts_as_commentable :admin
  default_scope { where(blocked: false) }
  
  def mailboxer_email(messageable)
    email
  end
  validates_date :birthdate, :on_or_before => lambda { Date.current }
  has_attached_file :avatar, :styles => {:small => "100x100#", medium: "300x300>", :large => "500x500>"},
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.jpg",
                    url: "/system/avatars/:hash.:extension", hash_secret: "laVieEstBelllllee", :hash_data => "/:attachment/:id/:style"
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :message => 'file type is not allowed (only jpeg/png/gif images)'
  before_avatar_post_process :reset_avatar_score

  delegate :wallets, :normal_wallet, :bonus_wallet, :transaction_wallet,
            :total_wallets_in_cents, :bank_accounts, to: :mangopay

  # MANGOPAY
  def mangopay
    @mangopay ||= MangoUser.new(self)
  end

  def is_solvable?(amount)
    amount < total_wallets_in_cents/100
  end

  def address
    self.mango_id.present? ? mangopay.address : Hashie::Mash.new({})
  end

  def country_of_residence
    mangopay.country_of_residence if self.mango_id.present?
  end

  # GENERAL
  def online?
    last_seen > 10.minutes.ago unless last_seen.nil?
  end
  
  def send_notification (subject, body, sender, obj=nil)
    notification = self.notify(subject, body, obj, true, 100, false, sender)
    PrivatePub.publish_to '/notifications/'+self.id.to_s, :notification => notification
  end

  def self.reader_scope
    where(:admin => true)
  end

  def name
    "#{firstname} #{lastname}".presence || email
  end
  alias username name

  def level_max
    Degree.where(:user_id => self).map { |t| t.level }.max.try(:id)
  end

  def nationality
    mangopay.nationality if self.mango_id.present?
  end

  # Methode permettant de faire passer un User à Student
  def upgrade
    self.type = User::ACCOUNT_TYPES[0]
    self.save!
  end

  #prevents a user from signin in
  def block
    self.update blocked: true
  end
  def unblock
    self.update blocked: false
  end

  # Types de User possibles
  def self.types
    %w(User Student Teacher)
  end

  # Methode permettant de rendre un User admin
  def become_admin
    self.admin=true
    self.save!
  end

  def is_admin?
    self.admin
  end

  def offers_except_other
    Offer.joins(:topic).where(user_id: id).where.not(topics:{title: 'Autre'})
  end

  # Méthode liée au crop de l'avatar, elle permet de savoir si une modification a été faite
  def cropping?
    [crop_x, crop_y, crop_w, crop_h].all?(&:present?)
  end

  def self.from_omniauth(auth)
    @provider = auth.provider
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        case @provider
          when "twitter"
            user.firstname = auth.info.name
            user.lastname = auth.info.nickname
            user.email = auth.info.email
            user.description = auth.info.description
            #user.birthdate = auth.info.birthdate
            user.password = Devise.friendly_token[0,20]
            user.confirmed_at = DateTime.now.to_date
            user.avatar = auth[:extra][:raw_info][:profile_image_url]
          when "facebook"
            user.firstname = auth.info.first_name
            user.lastname = auth.info.last_name
            #user.birthdate = auth.extra.raw_info.birthdate
            #user.gender = auth.extra.raw_info.gender
            user.password = Devise.friendly_token[0,20]
            user.email = auth.info.email
            user.avatar = URI.parse(auth.info.image) if auth.info.image?
            user.confirmed_at = DateTime.now.to_date
          when "linkedin"
            user.firstname = auth.raw_info.firstName
            user.lastname = auth.r_basicprofile.last-name
            user.email = auth.r_emailaddress.email-address
            #user.description = auth.r_basicprofile.summary
            user.password = Devise.friendly_token[0,20]
            user.avatar = auth.r_basicprofile.picture-urls
            user.confirmed_at = DateTime.now.to_date
          when "google_oauth2"
            user.firstname = auth.info.first_name 
            user.lastname = auth.info.last_name 
            user.birthdate = auth.extra.raw_info.birthdate
            user.gender = auth.extra.raw_info.gender
            user.password = Devise.friendly_token[0,20]
            user.email = auth.info.email 
            user.avatar = URI.parse(auth.info.image) if auth.info.image?
            user.confirmed_at = DateTime.now.to_date
        end
    end
  end

 def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
 end

  def qwerteach_score
    0
  end

  def age
    now = Time.now.utc.to_date
    now.year - birthdate.year - ((now.month > birthdate.month || (now.month == birthdate.month && now.day >= birthdate.day)) ? 0 : 1)
  end

  def reload(options = nil)
    @mangopay = nil
    super
  end
  
  def full_number
    "#{phone_country_code}#{phone_number}"
  end

  def profil_complete?
    (firstname.nil? || lastname.nil? || avatar.nil? || full_number.nil? || mango_id.nil?)
  end

  def reply(conversation, recipients, reply_body, subject=nil, sanitize_text=true, attachment=nil)
    subject = subject || "#{conversation.subject}"
    response = Mailboxer::MessageBuilder.new({
                                                 :sender       => self,
                                                 :conversation => conversation,
                                                 :recipients   => recipients,
                                                 :body         => reply_body,
                                                 :subject      => subject,
                                                 :attachment   => attachment
                                             }).build

    response.recipients.delete(self)
    #logger.debug(response.deliver.errors.full_messages.to_sentence)
    response.deliver true, sanitize_text
  end

  def can_send_sms?
    # to do: add user preference to sms sending
    valid_number? && sms_allowed?
  end

  def valid_number?
    Phony.plausible?(full_number)
  end

  def sms_allowed?
    sms_allowed
  end

  def active_for_authentication?
    super && !self.blocked
  end

  def active?
    self.active
  end

  protected
  # def confirmation_required?
  #   false
  # end

  private
    def reprocess_avatar
      avatar.assign(avatar)
      avatar.save
    end
  
    def reset_avatar_score
      self.avatar_score = 0
    end
  
  #def skip_confirmation!
    #self.confirmed_at = Time.now
  #end
end
