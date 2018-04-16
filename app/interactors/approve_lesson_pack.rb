class ApproveLessonPack < ActiveInteraction::Base
  object :lesson_pack, class: LessonPack
  array :transactions
  symbol :payment_method

  def execute
    LessonPack.transaction do
      lesson_pack.paid!
      lesson_pack.lessons = build_lessons
      if lesson_pack.save
        notify
      else
        errors.merge!(lesson_pack.errors)
      end
    end
    return lesson_pack
  end

  private

  def normal_transaction
    transactions.first
  end

  def bonus_transaction
    transactions.size > 1 ? transactions.last : nil
  end

  def build_lessons
    lesson_pack.items.map do |item|
      build_lesson_by_item(item)
    end
  end

  def build_lesson_by_item(item)
    lesson = Lesson.new({
      status: Lesson.statuses[:created],
      teacher_id: lesson_pack.teacher_id,
      student_id: lesson_pack.student_id,
      topic_id: lesson_pack.topic_id,
      topic_group_id: lesson_pack.topic.topic_group_id,
      level_id: lesson_pack.level_id,
      time_start: item.time_start,
      time_end: item.time_start + item.duration.minutes,
      price: lesson_price,
    })
    lesson.payments = [ build_payment(lesson) ]
    lesson
  end

  def lesson_price
    @lesson_price ||= lesson_pack.amount / lesson_pack.items.size
  end

  def bonus_amount
    bonus_transaction.credited_funds.amount.to_f / 100
  end

  def convert_payment_method(method)
    case method
    when :credit_card then :creditcard
    when :bancontact then :bcmc
    when :transfert then :wallet
    else :unknown
    end
  end

  def build_payment(lesson)
    Payment.new({
      payment_type: :prepayment,
      payment_method: convert_payment_method(payment_method),
      status: :locked,
      lesson_id: lesson.id,
      transfert_date: DateTime.now,
      price: lesson.price,
      mangopay_payin_id: normal_transaction.id,
      transfer_eleve_id: normal_transaction.id,
      transfer_bonus_id: bonus_transaction ? bonus_transaction.id : nil,
      transfer_bonus_amount: bonus_transaction ? bonus_amount / lesson_pack.items.size : nil,
      transactions: transactions
    })
  end

  def notify
    LessonPackNotificationsJob.perform_async(:notify_teacher_about_paid_lesson_pack, lesson_pack.id)
  end

end