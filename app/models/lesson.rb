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
  def self.async_send_notifications
    Resque.enqueue(LessonsNotifierWorker)
  end
end
