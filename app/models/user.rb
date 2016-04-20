class User < ActiveRecord::Base
  GENDER_TYPES = ["Not telling", "Male", "Female"]
  ACCOUNT_TYPES = ["Student", "Teacher"]
  TEACHER_STATUS = ["Actif", "Suspendu"]
  paginates_per 1

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
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable
  # Avatar attaché au User
  has_attached_file :avatar, :styles => {:small => "100x100#", medium: "300x300>", :large => "500x500>"},
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.jpg",
                    url: "/system/avatars/:hash.:extension", hash_secret: "laVieEstBelllllee", :hash_data => "/:attachment/:id/:style"
  # Vérifie que le type de l'avatar est bien une image
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :message => 'file type is not allowed (only jpeg/png/gif images)'
  # Attributs pour le crop de l'avatar
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h

  # Attributs pour mangopay
  attr_accessor :address, :nationality, :countryOfResidence, :bank_accounts
  # Vérifie que la date de naissance est bien dans le passé
  validates_date :birthdate, :on_or_before => lambda { Date.current }
  # Update de l'avatar pour le crop
  after_update :reprocess_avatar, :if => :cropping?
  has_one :gallery
  has_many :adverts

  # on crée une gallery après avoir créé le user
  after_create :create_gallery

  has_many :sent_comment, :class_name => 'Comment', :foreign_key => 'sender_id'
  has_many :received_comment, :class_name => 'Comment', :foreign_key => 'subject_id'
  # for gem unread
  acts_as_reader


  def send_notification (subject, body, sender)
    notification = self.notify(subject, body, nil, true, 100, false, sender)
    PrivatePub.publish_to '/notifications/'+self.id.to_s, :notification => notification
  end

  def self.reader_scope
    where(:is_admin => true)
  end

  #required for BBB
  def name
    self.firstname+' '+self.lastname
  end
  def username
    self.name
  end

  acts_as_messageable

  def level_max
    if Degree.where(:user_id => self).map { |t| t.level }.max.blank?
      nil
    else
      Degree.where(:user_id => self).map { |t| t.level }.max.id
    end
    #self.degrees.map{|t| t.level}.max.id
  end

  # Méthode permettant de créer une gallery
  def create_gallery
    Gallery.create(:user_id => self.id)
  end

  # Méthode permettant de créer une postulation
  def create_postulation
    Postulation.create(:user_id => self.id)
  end

  def mango_infos (params)
    {
        :FirstName => self.firstname,
        :LastName => self.lastname,
        :Address => params[:Address],
        :Birthday => self.birthdate.to_time.to_i,
        :Nationality => params[:Nationality],
        :CountryOfResidence => params[:CountryOfResidence],
        :PersonType => "NATURAL",
        :Email => self.email,
        :Tag => "user "+self.id.to_s()
    }
  end

  def load_mango_infos
    if self.mango_id?
      m = MangoPay::NaturalUser.fetch(self.mango_id)
      self.address = m['Address']
      self.countryOfResidence = m['CountryOfResidence']
      self.nationality = m['Nationality']
    else
      self.address = {}
    end
  end

  def load_bank_accounts
    if self.mango_id?
      self.bank_accounts = MangoPay::BankAccount.fetch(self.mango_id)
    end
  end

  def create_mango_user (params)
    m = {}
    if !(self.mango_id?)
      m = MangoPay::NaturalUser.create(mango_infos(params))
      self.mango_id = m['Id']
      self.save
      MangoPay::Wallet.create({
                                  :Owners => [self.mango_id],
                                  :Description => "wallet user " + self.id.to_s,
                                  :Currency => "EUR"
                              })
      MangoPay::Wallet.create({
                                  :Owners => [self.mango_id],
                                  :Description => "wallet bonus user " + self.id.to_s,
                                  :Currency => "EUR",
                                  :Tag => "Bonus"
                              })
      MangoPay::Wallet.create({
                                  :Owners => [self.mango_id],
                                  :Description => "wallet transfert user " + self.id.to_s,
                                  :Currency => "EUR",
                                  :Tag => "Transfert"
                              })
    else
      m = MangoPay::NaturalUser.update(self.mango_id, mango_infos(params))
    end
    m
  end

  # Méthode liée au crop de l'avatar, elle permet de savoir si une modification a été faite
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  # Méthode liée au crop de l'avatar
  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  private
  def reprocess_avatar
    avatar.assign(avatar)
    avatar.save
  end

  # Methode permettant de faire passer un User à Student
  public
  def upgrade
    self.type=ACCOUNT_TYPES[0]
    self.save
  end

  belongs_to :level
  # Méthode permettant de savoir si le User est admin
  public
  def admin?
    admin
  end

  # Types de User possibles
  def self.types
    %w(User Student Teacher)
  end

  # Methode permettant de savoir si le User est un prof postulant
  public
  def is_prof_postulant
    false
  end

  # Methode permettant d'accepter la postulation  d'un prof

  public
  def accept_postulance
  end

  # Methode permettant de savoir si la postulation a été acceptée par un admin
  public
  def is_prof
    false
  end

  # Methode permettant de rendre un User admin
  public
  def become_admin
    self.admin=true
    self.save
  end

  def mailboxer_email(object)
    self.email
    #return the model's email here
  end
end