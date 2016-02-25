class User < ActiveRecord::Base
  GENDER_TYPES = ["Not telling", "Male", "Female"]
  ACCOUNT_TYPES = ["Student", "Teacher"]
  TEACHER_STATUS = ["Actif", "Suspendu"]


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
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.jpg"
  # Vérifie que le type de l'avatar est bien une image
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :message => 'file type is not allowed (only jpeg/png/gif images)'
  # Attributs pour le crop de l'avatar
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  # Vérifie que la date de naissance est bien dans le passé
  validates_date :birthdate, :on_or_before => lambda { Date.current }
  # Update de l'avatar pour le crop
  after_update :reprocess_avatar, :if => :cropping?

  has_one :gallery
  has_one :postulation
  has_many :conversations, :foreign_key => :sender_id

  # on crée une postulation et une gallery après avoir créé le user
  after_create :create_gallery, :create_postulation

  has_many :sent_comment, :class_name => 'Comment', :foreign_key => 'sender_id'
  has_many :received_comment, :class_name => 'Comment', :foreign_key => 'subject_id'

  # Méthode permettant de créer une gallery
  def create_gallery
    Gallery.create(:user_id => self.id)
  end
  # Méthode permettant de créer une postulation
  def create_postulation
    Postulation.create(:user_id => self.id)
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
end