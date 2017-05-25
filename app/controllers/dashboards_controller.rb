class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user
    @upcoming_lessons = Lesson.created.involving(@user).first(4)

    unless(@user.mango_id.nil?)
      @wallets = {normal: @user.wallets.first, bonus: @user.wallets.second, transfer: @user.wallets.third}
    end

    @pending_lessons = @user.pending_lessons
    @featured_topics = TopicGroup.where(featured: true) + Topic.where(featured: true)
    @featured_teachers = Teacher.all.order(score: :desc).limit(4)
    @current_lesson = @user.current_lesson

    @to_unlock_lessons = @user.lessons_received.to_unlock
    @to_review_lessons = @user.lessons_received.to_review(@user).where.not(id: @to_unlock_lessons.ids).group(:teacher_id)
    @to_pay_lessons = @user.lessons_received.where(pay_afterwards: true).includes(:payments).where(payments: {id: nil})
    @to_unlock_lessons = @to_unlock_lessons + @to_pay_lessons
  end
end
