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
  #validates_datetime :time_start, :on_or_after => lambda { DateTime.current }
  validates :time_end, presence: true
  #validates_datetime :time_end, :after => :time_start
  validates :topic_group_id, presence: true
  validates :level_id, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }
  validate :expected_price

  def self.past
    where("time_end < ?", DateTime.now)
  end
  def self.upcoming
    where("time_start > ?", DateTime.now)
  end
  def self.occuring
    where("time_end > ? AND time_start < ?", DateTime.now, DateTime.now)
  end

  def self.async_send_notifications
    Resque.enqueue(LessonsNotifierWorker)
  end

  def expected_price
    if free_lesson
      if price !=0
        errors.add(:price, "Le prix d'un cours d'essai est toujours zéro!")
      end
    else
      right_time = ((time_end.beginning_of_minute()  - time_start.beginning_of_minute() ) / 3600).to_f
      right_price = Advert.get_price(User.find(teacher), Topic.find(topic), Level.find(level)) * right_time
      if price.to_f != right_price
        errors.add(:price, "Le prix n'est pas correct.")
      end
    end

  end

  def paid?
    paid = true
    self.payments.each do |payment|
      paid = false if payment.pending?
    end
    paid
  end

  def pending?(user)
    (teacher == user && status == 'pending_teacher') || (student == user && status == 'pending_student')
  end

  def other(user)
    if user.id == student.id
      teacher
    else
      student
    end
  end

  def upcoming?
    time_start > DateTime.now
  end

  def review_needed?(user)
    if user.id != student_id
      return false
    else
      Review.where('sender_id = ? AND subject_id = ?', student.id, teacher.id).empty?
    end
  end
end
