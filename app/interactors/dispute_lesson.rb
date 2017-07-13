class DisputeLesson < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson

  validate :lesson_has_not_dispute

  def execute
    # find all payments of the lesson (most cases only one)
    # make transfer for all payments that are locked

    Lesson.transaction do
      dispute = Dispute.create(user: user, lesson: lesson)
      lesson.reload.payments.each do |payment|
        payment.status = 'disputed'
        if !payment.save
          self.errors.merge! payment.errors
          raise ActiveRecord::Rollback
        end
      end
      dispute
    end
  end

  private

  def lesson_has_not_dispute
    errors.add(:base, I18n.t('dispute_lesson.already_in_dispute')) if lesson.dispute.present?
  end
end