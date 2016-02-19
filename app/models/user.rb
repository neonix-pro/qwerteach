class User < ActiveRecord::Base
  GENDER_TYPES = ["Not telling", "Male", "Female"]
  ACCOUNT_TYPES = ["Student", "Teacher"]


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable


  #
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

  has_attached_file :avatar, :styles => {:small => "100x100#", medium: "300x300>", :large => "500x500>"},
                    :processors => [:cropper], default_url: "/system/defaults/:style/missing.jpg"
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png', 'image/gif']
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  validates_date :birthdate, :on_or_before => lambda { Date.current }

  after_update :reprocess_avatar, :if => :cropping?
  has_one :gallery

  after_create :create_gallery
  def create_gallery
    Gallery.create(:user_id=>self.id)
  end

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def avatar_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(avatar.path(style))
  end

  private
  def reprocess_avatar
    avatar.assign(avatar)
    avatar.save
  end

  public
  def upgrade
    self.type=ACCOUNT_TYPES[0]
    / if self.type==ACCOUNT_TYPES[0]
      self.type=ACCOUNT_TYPES[1]
    else
      self.type=ACCOUNT_TYPES[2]
    end/
    self.save
  end

  belongs_to :level
  public
  def admin?
    admin
  end

  def self.types
    %w(User Student Teacher)
  end
  /  def self.build_admin(params)
    user = User.new(params)
    user.admin = true
    user
  end/
  public
  def is_prof_postulant
    false
  end

  public
  def accept_postulance
  end

end