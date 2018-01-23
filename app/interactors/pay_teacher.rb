class PayTeacher < ActiveInteraction::Base
  object :user, :class => User
  object :lesson, :class => Lesson

  set_callback :execute, :after, :send_notifications

  def execute
    # find all payments of the lesson (most cases only one)
    # make transfer for all payments that are locked

    Lesson.transaction do
      return self.errors.merge!(lesson.errors) if !lesson.save
      lesson.payments.each do |payment|

        if payment.locked?
          transfer = Mango::TransferBetweenWallets.run(transfer_params(payment))
        end

        if !transfer.valid?
          self.errors.merge! transfer.errors
          raise ActiveRecord::Rollback
        end
        payment.status = 'paid'
        #payment.transfer_prof_id = transfer.result.id
        if !payment.save
          self.errors.merge! payment.errors
          Rails.logger.debug("Impossible de sauver le payement. #{payment.errors.full_messages.to_sentence}")
          raise ActiveRecord::Rollback
        end
        return transfer.result
      end
    end
  end

  private

  def send_notifications
    return if errors.any?
    LessonNotificationsJob.perform_async(:notify_teacher_about_lesson_payment_unlocked, lesson.id)
    Pusher.notify(["#{lesson.teacher.id}"], {fcm: {notification: {body: "Le payement de votre cours avec #{lesson.student.name} a été débloqué.", 
            icon: 'androidlogo', click_action: "MY_LESSONS"}}})
  end

  def student
    lesson.student
  end

  def teacher
    lesson.teacher
  end

  def amount(payment)
    payment.price
  end

  def transfer_params(payment)
    {
        user: user,
        amount: amount(payment),
        debited_wallet_id: student.transaction_wallet.id,
        credited_wallet_id: teacher.normal_wallet.id
    }
  end

end