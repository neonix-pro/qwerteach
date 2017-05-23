class Lesson < ActiveRecord::Base
  require 'nexmo'
  # meme nom que dans DB sinon KO.
  # cf schéma etats de Lesson
  enum status: [:pending_teacher, :pending_student, :created, :canceled, :refused, :expired]

  # User qui recoit le cours
  belongs_to :student, :class_name => 'User', :foreign_key  => "student_id"
  # User qui donne le cours
  belongs_to :teacher, :class_name => 'User', :foreign_key  => "teacher_id"

  belongs_to :topic_group
  belongs_to :topic
  belongs_to :level

  has_many :payments, inverse_of: :lesson

  has_one :bbb_room

  scope :pending, ->{where("lessons.status IN (?) ", [0, 1])}
  scope :created, ->{where("lessons.status LIKE ? ", 2)}
  scope :locked, ->{joins(:payments).where("payments.status LIKE ?", 1)}
  scope :locked_or_paid, ->{joins(:payments).where("payments.status IN (?)", [1, 2])}
  scope :payment_pending, ->{joins(:payments).where("payments.status LIKE ?", 0)} # money isn't locked. Postpay lesson
  scope :past, ->{where("time_start < ? ", Time.now)}
  scope :future, ->{where("time_start > ? ", Time.now)}
  scope :involving, ->(user){where("teacher_id = ? OR student_id = ?", user.id, user.id).order(time_start: 'desc')}
  scope :is_student, ->(user){where("student_id = ?", user.id)}
  scope :active, ->{where.not("lessons.status IN(?)", [3, 4])} # not canceled or refused or expired

  scope :upcoming, ->{ active.future } #future and (created or pending)
  scope :passed, ->{past.created} # lessons that already happened
  scope :expired, ->{where("lessons.status LIKE ? ", 5)}
  scope :to_answer, ->{pending.locked.future} # lessons where we're waiting for an answer
  scope :to_unlock, ->{created.locked.past} # lessons where we're waiting for student to unlock money
  scope :to_pay, ->{created.payment_pending.past} # lessons that haven't been prepaid and student needs to pay

  scope :to_review, ->(user){created.locked_or_paid.past.joins('LEFT OUTER JOIN reviews ON reviews.subject_id = lessons.teacher_id
    AND reviews.sender_id = lessons.student_id')
    .where(:student => user.id)
    .where('reviews.id is NULL')
    .where('time_end < ?', DateTime.now)
    .group(:teacher_id)}
  
  scope :with_room, -> {joins(:bbb_room).select("DISTINCT lessons.*")}
  scope :without_room, -> {includes(:bbb_room).where(:bigbluebutton_rooms => { :id => nil })}

  scope :needs_pay, ->{ created.where('price > 0').where('NOT EXISTS( SELECT 1 FROM payments WHERE status = 2 AND lesson_id = lessons.id )') }

  has_drafts

  validates :student_id, presence: true
  validates :teacher_id, presence: true
  validates :status, presence: true
  validates :time_start, presence: true
  #validates_datetime :time_start, :on_or_after => lambda { DateTime.current }
  validates :time_end, presence: true
  validates_datetime :time_end, :after => :time_start
  validates :topic_group_id, presence: true
  validates :level_id, presence: true
  validates :price, presence: true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }

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

  # fin de l'histoire, c'est payé au prof
  def paid?
    return true if free_lesson
    return false if payments.empty?
    return false if payments.any?{|payment| !payment.paid?}
    true
  end

  # l'élève a payé mais le prof n'a pas encore touché l'argent
  def prepaid?
    return false if payments.empty?
    return true if payments.any?{|payment| payment.locked? }
    false
  end

  # le user doit-il confirmer?
  def pending?(user = nil)
    return pending_any? if user.nil?
    (teacher == user && status == 'pending_teacher') || (student == user && status == 'pending_student')
  end

  def to_expire?
    (status == 'pending_teacher' || status == 'pending_student') && time_start < Time.now
  end

  def expired?
    status == 'expired'
  end

  def canceled?
    status == 'canceled'
  end
  def refused?
    status == 'refused'
  end
  def created?
    status == 'created'
  end

  def active?
    !(expired? || status == 'canceled' || status == 'refused')
  end

  def other(user)
    if student && user.id == student.id
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

  def can_start?
    free_lesson? or pay_afterwards or paid? or prepaid?
  end

  def pending_any?
    pending_student? || pending_teacher?
  end

  def is_teacher?(user)
    user.id == teacher_id
  end
  def is_student?(user)
    user.id == student_id
  end

  def disputed?
    payments.each do |p|
      if p.disputed?
        return true
      end
    end
    return false
  end

  def to_pay?(user)
    if created? && is_student?(user)
      payments.each do |p|
        if p.pending? || p.locked?
          return true
        end
      end
    end
    false
  end

  # defines if the user needs to do something with the lesson:
  # inactive: the lesson is canceled, refused, or has expired
  # wait: We're waiting for the other user to do something, or for the lesson to happen
  # confirm: accept or decline the lesson request
  # unlock: confirm that all went ok and pay the teacher
  # pay: lesson is post paid and need to be paid
  # review: please leave a review of this teacher
  # disputed: this lesson's payment is disputed
  # nil return nil if the leson is passed and everything is OK
  def todo(user)
    return :inactive unless active?
    return :confirm if pending?(user)
    if past? && is_student?(user)
      return :disputed if disputed?
      unless paid?
        return :unlock if prepaid?
        return :pay
      end
    end
    return :review if review_needed?(user)
    return nil if past? && paid?
    :wait
  end

  def alternate_pending
    return 1 if pending_teacher? #pending_student
    return 0 if pending_student? #pending_teacher
  end

  #notifies other that he's got a new request
  def notify_user(user)
    @user = user
    @other = self.other(@user)
    @notification_text = "#{@other.name} vous adresse une demande de cours."
    @other.send_notification(@notification_text, '#', @user, self)
    Rails.logger.debug(@notification_text)
    @lesson = self
    # send sms
    if @other.can_send_sms?
      client = Nexmo::Client.new()
      response = client.send_message(from: 'Qwerteach', to: @other.full_number, text: @notification_text)
    end
    LessonMailer.new_lesson(@other, @lesson, @notification_text).deliver
  rescue
    raise if ENV['SKIP_NOTIFICATION_ERRORS'].blank?
  end

  def can_cancel?(user)
    (self.teacher == user || self.time_start > Time.now + 2.days || self.pending_any?)
  end

  def as_json(options = {})
    super.merge({
        :id => self.id,
        :title => "#{self.topic.title}",
        :start => time_start.rfc822,
        :end => time_end.rfc822,
        :allDay => false,
        :user_name => self.teacher.name,
        :color => "#22de80"
    })
  end

  private
end
