module LessonsHelper

  def date_for_display(date)
    fsdate = (date == nil)? date :  I18n.l( DateTime.parse(date.localtime.to_s), :format => :short)
  end

  def lesson_duration(starttime, endtime)
    d = endtime - starttime
    hours = (d / 3600).to_int
    minutes = ((d % 3600) / 60).to_int
    r = (hours < 1 ? '' : "#{hours}h") + (minutes == 0 ? "" :"#{minutes}min")
  end

  def lesson_confirmation_status(lesson)
    if lesson.status == 'pending_teacher' || lesson.status =='pending_student'
      return 'pending'
    end
    if lesson.status =='canceled' || lesson.status == 'refused'
      return 'canceled'
    end
    return 'created'
  end

  def lesson_payment_status(lesson)
    if lesson.paid?
      return 'paid'
    end
    if lesson.prepaid?
      if lesson.student.id == current_user.id
        return 'paid' #le vlient, on lui affiche payé ou non payé. Le reste, ça le rend confus.
      else
        return 'prepaid'
      end
    end
    return 'unpaid'
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

  def payment_status(status)
    case status
      when 'pending'
        "Le paiement n'a pas encore été effectué par l'élève"
      when 'locked'
        "Le paiement a été effectué par l'élève et est détenu par Qwerteach"
      when 'canceled'
        "Le paiement a été annulé"
      when 'refunded'
        "Le paiement a été retourné à l'élève et crédité sur son poretefeuille virtuel Qwerteach"
      when 'paid'
        "le paiement a été versé au professeur"
      when 'disputed'
        "le paiement est détenu par Qwerteach. Notre équipe cherche avec vous une solution"
    end
  end

  def options_for_hours_select
    Array.new(5) { |i| [ "0#{i}", i ] }
  end

  def options_for_minutes_select
    [['00', 0], ['15', 15], ['30', 30], ['45', 45]]
  end

end
