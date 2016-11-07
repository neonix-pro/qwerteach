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

  scope :involving, ->(user){where("teacher_id LIKE ? OR student_id LIKE ?", user.id, user.id).order(time_start: 'desc')}
  scope :active, ->{where.not("lessons.status IN(?)", [3, 4])}
  scope :upcoming, ->{ active.where("time_start > ?", Time.now) }
  scope :passed, ->{active.where("time_start < ?", Time.now)}
  scope :to_be_paid, ->{passed.joins(:payments).where("payments.status LIKE ?", 1)} # payments with 'locked' status
  scope :to_answer, ->{upcoming.where(status: [0, 1])}
  scope :expired, ->{passed.where("lessons.status LIKE (?)", 2)}

  #to show in index of lessons
  scope :index, ->{joins(:payments).active.where("time_start > ? OR (lessons.status LIKE ? AND payments.status LIKE ? )", Time.now, 2, 1)}

  has_drafts

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
  def self.created
    where(status: 2)
  end

  def self.async_send_notifications
    Resque.enqueue(LessonsNotifierWorker)
  end

  def duration
    @duration ||= Duration.new((time_start || 0) - ((time_start and time_end) || 0))
  end

  def expected_price
    if free_lesson
      errors.add(:price, "Le prix d'un cours d'essai est toujours zéro!") if price !=0
    else
      right_price = CalculateLessonPrice.run({
        teacher_id: teacher_id,
        hours: duration.total_hours,
        minutes: duration.minutes,
        level_id: level_id,
        topic_id: topic_id
      }).result

      errors.add(:price, "Le prix n'est pas correct.") if price.to_f != right_price
    end

  end

  # fin de l'histoire, c'est payé au prof
  def paid?
    paid = true
    self.payments.each do |payment|
      paid = false unless payment.paid?
    end
    if self.payments.empty?
      paid = false
    end
    if self.free_lesson
      paid = true
    end
    paid
  end
  # l'élève a payé mais le prof n'a pas encore touché l'argent
  def prepaid?
    if payments.empty?
      return false
    end
    payments.each do |payment|
      if payment.postpayment? || payment.pending?
        return false
      end
    end
    return true
  end

  # le user doit-il confirmer?
  def pending?(user = nil)
    if user.nil?
      return pending_any?
    end
    (teacher == user && status == 'pending_teacher') || (student == user && status == 'pending_student')
  end

  def expired?
    (status == 'pending_teacher' || status == 'pending_student') && time_start < Time.now
  end

  def canceled?
    status == 'canceled'
  end
  def refused?
    status == 'refused'
  end

  def active?
    !(expired? || status == 'canceled' || status == 'refused')
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
  def past?
    time_end < DateTime.now
  end

  def review_needed?(user)
    if user.id != student_id
      return false
    else
      Review.where('sender_id = ? AND subject_id = ?', student.id, teacher.id).empty? && past?
    end
  end

  def created?
    status == 'created'
  end
  def pending_teacher?
    status == 'pending_teacher'
  end

  def pending_student?
    status == 'pending_student'
  end

  def pending_any?
    pending_student? || pending_teacher?
  end

  def is_teacher?(user)
    user.id == teacher.id
  end
  def is_student?(user)
    user.id == student.id
  end

  def disputed?
    payments.each do |p|
      if p.disputed?
        return true
      end
    end
    return false
  end

  # defines if the user needs to do something with the lesson:
  # inactive: the lesson is canceled, refused, or has expired
  # wait: We're waiting for the other user to do something, or for the lesson to happen
  # confirm: accept or decline the lesson request
  # unlock: confirm that all went ok and pay the teacher
  # pay: lesson is post paid and need to be paid
  # review: please leave a review of this teacher
  # disputed: this lesson's payment is disputed
  def todo(user)
    unless active?
      return :inactive
    end
    if pending?(user)
      return :confirm
    end
    if past? && is_student?(user)
      if disputed?
        return :disputed
      end
      if prepaid?
        return :unlock
      end
      unless paid?
        return :pay
      end
    end
    if review_needed?(user)
      return :review
    end
    return :wait
  end
end
