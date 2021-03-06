class User < ActiveRecord::Base
  after_initialize :anonymize_deleted
  GENDER_TYPES = ["Not telling", "Male", "Female"]
  ACCOUNT_TYPES = ["Student", "Teacher", "Parent"]

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
         :lastseenable, :confirmable, password_length: 8..128
          #, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]

  phony_normalize :phone_number, as: :full_number, default_country_code: :phone_country_code

  has_one :gallery, dependent: :destroy
  has_many :offers, dependent: :destroy
  before_save -> { skip_reconfirmation! }
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
  before_create { self.description ||= '' }

  validates :type, inclusion: { in: ACCOUNT_TYPES,
                                message: "type d'utilisateur non valide" }

  acts_as_messageable
  acts_as_commentable :admin
  #default_scope { where(blocked: false) }
  
  def mailboxer_email(messageable)
    email
  end
  validates_date :birthdate, :on_or_before => lambda { Date.current }
  has_attached_file :avatar, :styles => {:small => "100x100#", medium: "300x300>", :large => "500x500>"},
                    :processors => [:cropper],
                    url: "/system/avatars/:hash.:extension", hash_secret: "laVieEstBelllllee", :hash_data => "/:attachment/:id/:style",
                    default_url: :adorable_avatar
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :message => 'file type is not allowed (only jpeg/png/gif images)'
  before_avatar_post_process :reset_avatar_score

  delegate :wallets, :normal_wallet, :bonus_wallet, :transaction_wallet,
            :total_wallets_in_cents, :bank_accounts, to: :mangopay

  scope :reader_scope, -> { where(admin: true) }
  scope :active, ->{ where(active: true) }
  scope :for_select, ->{ select(:id, :firstname, :lastname, :email).reorder(:firstname).distinct }
  scope :review_senders, ->{ joins(:reviews_sent) }
  scope :review_receivers, ->{ joins(:reviews_received) }
  scope :online, ->{ where('last_seen > ?', 10.minutes.ago) }
  scope :with_payments_count, -> {
    lessons = Lesson.arel_table
    payments = Payment.arel_table

    composed_cte = Arel::Nodes::As.new(
        lessons.project(:student_id, payments[:id].count.as('payments_count'))
            .join(payments, Arel::Nodes::OuterJoin).on( payments[:lesson_id].eq(lessons[:id]).and(payments[:status].eq(2)) )
            .group(lessons[:student_id]), Arel::Table.new(:payments_cte))

    select('users.*, COALESCE(payments_cte.payments_count, 0) AS payments_count')
        .joins("LEFT JOIN #{composed_cte.to_sql} ON payments_cte.student_id = users.id")
  }

  def adorable_avatar
    "https://api.adorable.io/avatars/#{ email }"
  end

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
  
  def send_notification (subject, body, sender, obj=nil, code=100)
    n = self.notify(subject, body, obj, true, code, false, sender)
    notification = Notification.new(subject: subject, body: body, notification_code: code)
    PrivatePub.publish_to '/notifications/'+self.id.to_s, :notification => notification
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

  def drip_custom_fields
    {firstname: firstname, lastname: lastname, birthdate: birthdate}
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
            #user.birthdate = auth.extra.raw_info.birthdate
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

  def full_name
    [firstname.presence, lastname.presence].compact.join(' ')
  end

  def time_zone_hours_offset
    ActiveSupport::TimeZone.new(time_zone).utc_offset / 3600
  end

  def gdpr_attributes
    self.attributes.except!("encrypted_password", "reset_password_token", "confirmation_token", "unlock_token", "admin", "mango_id",
    "score", "response_rate", "response_time", "average_response_time", "avatar_score", "sms_allowed", "tokens", "authentication_token", "source"
    )
  end

  protected
  # def confirmation_required?
  #   false
  # end

  def validate_user_type

  end

  private
    def reprocess_avatar
      avatar.assign(avatar)
      avatar.save
    end

    def reset_avatar_score
      self.avatar_score = 0
    end
  
    def skip_confirmation!
      self.confirmed_at = Time.now
    end

    def anonymize_deleted
      if blocked?
        self.attributes = User.new({id: id, firstname: 'Profil', lastname: 'Supprimé'}).attributes
      end
    end
end
