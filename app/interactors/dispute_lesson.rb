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
      return lesson
    end
  end

  private


end