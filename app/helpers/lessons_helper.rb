module LessonsHelper
  def lesson_duration(starttime, endtime)
    d = endtime - starttime
    hours = (d / 3600).to_int
    minutes = ((d % 3600) / 60).to_int
    r = (hours < 1 ? '' : "#{hours}h") + (minutes == 0 ? "" :"#{minutes}min")
  end

  def lesson_status_class(lesson)
    if lesson.status == 'pending_teacher' || lesson.status =='pending_student'
      return 'lesson-pending'
    end
    if lesson.status =='canceled' || lesson.status == 'refused'
      return 'lesson-canceled'
    end
    if lesson.paid?
      return 'lesson-status-paid'
    else
      if lesson.upcoming?
        return 'lesson-status-upcoming'
      else
        return 'lesson-status-unpaid'
      end
    end
  end

  def lesson_payment_status(lesson)
    if lesson.prepaid?
      return 'prepaid'
    end
    if lesson.paid?
      return 'paid'
    end
  end

  def lesson_topic_class(lesson)
    "topic_#{lesson.topic.topic_group.id}"
  end

  def partial_action(lesson)
    if lesson.upcoming?
      if lesson.pending?(current_user)
        return 'pending'
      end
      if lesson.pending?(lesson.other(current_user))
        return 'show_pending'
      end
    else
      if lesson.pending?(current_user) || lesson.pending?(lesson.other(current_user))
        return 'expired'
      end
      unless lesson.paid?
        if current_user.id == lesson.student.id
          return 'payment'
        else
          return 'wait_payment'
        end
      end
      if lesson.review_needed?(current_user)
        return 'review'
      end
    end
  end
end
