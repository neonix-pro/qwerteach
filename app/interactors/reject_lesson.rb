class RejectLesson < ActiveInteraction::Base
  object :user, :class => User
  object :lesson, :class => Lesson

  def execute
    proposal = lesson.pending_any? ? true : false
    RefundLesson.run(user: user, lesson: lesson)
    if proposal
      send_notifications_proposal
    else
      send_notifications_lesson
    end
  end

  private



  def send_notifications_proposal
    return if errors.any?
    return if lesson.expired?
    if lesson.is_student?(user)
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_reject_lesson_proposal, lesson.id)
      Pusher.notify(["#{lesson.teacher.id}"], {fcm: {notification: {body: "#{lesson.student.name} a refusé votre demande de cours.",
                                                                    icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    else
      LessonNotificationsJob.perform_async(:notify_student_about_teacher_reject_lesson_proposal, lesson.id)
      Pusher.notify(["#{lesson.student.id}"], {fcm: {notification: {body: "#{lesson.teacher.name} a refusé votre demande de cours.",
                                                                    icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    end
  end

  def send_notifications_lesson
    return if errors.any?
    return if lesson.expired?
    if lesson.is_student?(user)
      LessonNotificationsJob.perform_async(:notify_teacher_about_student_reject_lesson, lesson.id)
      Pusher.notify(["#{lesson.teacher.id}"], {fcm: {notification: {body: "#{lesson.student.name} a refusé votre cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}.",
                                                                    icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    else
      LessonNotificationsJob.perform_async(:notify_student_about_teacher_reject_lesson, lesson.id)
      Pusher.notify(["#{lesson.student.id}"], {fcm: {notification: {body: "#{lesson.teacher.name} a refusé votre cours de #{lesson.topic.title} du #{lesson.time_start.strftime('%d/%m/%Y')}.",
                                                                    icon: 'androidlogo', click_action: "MY_LESSONS"}}})
    end
  end
end