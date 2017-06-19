class DisputeLesson < ActiveInteraction::Base
  object :user, class: User
  object :lesson, class: Lesson

  def execute
    # find all payments of the lesson (most cases only one)
    # make transfer for all payments that are locked

    Lesson.transaction do
      return self.errors.merge!(lesson.errors) if !lesson.save
      lesson.payments.each do |payment|
        payment.status = 'disputed'
        if !payment.save
          self.errors.merge! payment.errors
          raise ActiveRecord::Rollback
        end
      end
    end
    dispute
  end

  def dispute
    @dispute ||= Dispute.create(
      user: user,
      lesson: lesson
    )
  end

  private


end