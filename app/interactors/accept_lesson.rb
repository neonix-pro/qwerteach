class AcceptLesson < ActiveInteraction::Base

  object :user, class: User
  object :lesson, class: Lesson

  set_callback :execute, :before, :validate_access
  set_callback :execute, :after, :send_notifications

  def execute
    if lesson.can_start?
      lesson.status = :created
    else
      if teacher?
        lesson.status = :pending_student
      else
        errors.add :base, 'Needs to pay this lesson before'
        return lesson
      end
    end
    errors.merge(lesson.errors) unless lesson.save
    lesson
  end

  def other
    @other ||= lesson.other(user)
  end

  def teacher?
    lesson.is_teacher?(user)
  end

  def student?
    lesson.is_student?(user)
  end

  private

  def notification_text
    if teacher?
      "Le professeur #{@lesson.teacher.name} a accepté votre demande de cours."
    else
      "#{@lesson.student.name} a accepté la demande de cours pour le cours ##{@lesson.id}."
    end
  end

  def send_notifications
    return if errors.any?
    if teacher?
      LessonNotificationsJob.perform_async(:notify_student_about_teacher_accepts_lesson, lesson.id)
      LessonNotificationsJob.perform_async(:notify_teacher_about_teacher_accepts_lesson, lesson.id)
      Pusher.notify(["#{lesson.student.id}"], {fcm: {notification: {body: "#{lesson.teacher.name} a accepté votre demande de cours.", 
            icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    else
      LessonNotificationsJob.perform_async(:notify_student_about_student_accepts_lesson, lesson.id)
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_accepts_lesson, lesson.id)
      Pusher.notify(["#{lesson.teacher.id}"], {fcm: {notification: {body: "#{lesson.student.name} a accepté votre demande de cours.", 
            icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    end
  end

  def validate_access
    if lesson.student_id != user.id and lesson.teacher_id != user.id
      self.errors.add :base, 'You can\'t access to this lesson'
    end
  end

end