class SuggestLesson < ActiveInteraction::Base

  object :user, class: User

  integer :student_id
  time :time_start
  integer :hours
  integer :minutes, default: 0
  integer :topic_id
  integer :level_id
  boolean :pay_afterwards, default: false
  float :price
  string :comment, default: nil

  validates :student, :time_start, :hours, :minutes, :topic_id, :level_id, :price, presence: true

  set_callback :validate, :after, :validate_pay_afterwards
  set_callback :validate, :after, :validate_duration

  def student
    @student ||= Student.find_by(id: student_id) if student_id.present?
  end

  def execute
    lesson = Lesson.new(lesson_params)
    self.errors.merge!(lesson.errors) unless lesson.save
    lesson
  end

  def time_end
    time_start + hours.hours + minutes.minutes
  end

  private

  def validate_pay_afterwards
    return if student_id.blank?
    if Payment.select('lessons.student_id').paid.joins(:lesson).where(lessons: {student_id: student_id}).count == 0
      self.errors.add(:pay_afterwards, 'Can\'t be applicable for selected student')
    end
  end

  def validate_duration
    if hours + minutes <= 0
      self.errors[:base] << "la durée doit être supérieure à 0"
    end
  end

  def teacher_id
    user.id
  end

  def lesson_params
    inputs.slice(:student_id, :topic_id, :level_id, :time_start, :pay_afterwards, :price).merge({
      teacher_id: teacher_id,
      time_end: time_end,
      topic_group_id: Topic.find_by(id: topic_id).try(:topic_group_id),
      status: :pending_student
    })
  end

end