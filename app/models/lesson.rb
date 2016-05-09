class Lesson < ActiveRecord::Base
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Lesson
  enum status: [:pending_teacher, :pending_student, :created, :canceled, :refused]

  # User qui recoit le cours
  belongs_to :student, :class_name => 'User', :foreign_key  => "student_id"
  # User qui donne le cours
  belongs_to :teacher, :class_name => 'User', :foreign_key  => "teacher_id"

  belongs_to :topic_group
  belongs_to :topic
  belongs_to :level

  has_many :payments

  has_one :bbb_room

  validates :student_id, presence: true
  validates :teacher_id, presence: true
  validates :status, presence: true
  validates :time_start, presence: true
  validates_datetime :time_start, :on_or_after => lambda { DateTime.current }
  validates :time_end, presence: true
  validates_datetime :time_end, :after => :time_start, :after_message => "pipi"
  validates :topic_group_id, presence: true
  validates :level_id, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }

  def self.async_send_notifications
    Resque.enqueue(LessonsNotifierWorker)
  end
end
