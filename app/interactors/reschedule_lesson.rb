class RescheduleLesson < ActiveInteraction::Base
  STUDENT_RESCHEDULE_LIMIT = 1

  object :user, class: User
  object :lesson, class: Lesson
  time :new_date

  validate :student_can_reschedule_lesson_in_24_hours_before_begin
  validate :student_can_reschedule_only_once
  validate :new_date_should_be_after_24_hours_from_now

  def execute
    duration = lesson.time_end - lesson.time_start
    lesson.time_start = new_date
    lesson.time_end = new_date + duration
    lesson.rescheduled += 1 if lesson.is_student?(user)
    errors.merge!(lesson.errors) unless lesson.save
    lesson
  end

  private

  def student_can_reschedule_lesson_in_24_hours_before_begin
    if lesson.is_student?(user) && lesson.time_start < 24.hours.since
      errors.add(:base, "Vous ne pouvez pas déplacer ce cours car il a lieu dans moins de 24h.")
    end
  end

  def student_can_reschedule_only_once
    if lesson.is_student?(user) && lesson.rescheduled >= STUDENT_RESCHEDULE_LIMIT
      errors.add(:base, "Vous ne pouvez déplacer le cours de manière unilatérale qu'une fois.")
    end
  end

  def new_date_should_be_after_24_hours_from_now
    if new_date < 24.hours.since
      errors.add(:new_date, "La nouvelle date doit être au moins 24h dans le futur.")
    end
  end
end