class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @user = current_user
    @upcoming_lessons = Lesson.where(:status => 2).where('time_start > ?', DateTime.now).where("student_id =#{@user.id}  OR teacher_id = #{@user.id}")
    @past_lessons = Lesson.involving(@user).passed.with_room.limit(3).order(time_start: :desc)

    unless @past_lessons.empty?
      @book_again_lesson = @past_lessons.is_student(@user).first
      while @past_lessons.length < 3
        @past_lessons.append(nil)
      end
    end

    unless(@user.mango_id.nil?)
      @wallets = {normal: @user.wallets.first, bonus: @user.wallets.second, transfer: @user.wallets.third}
    end

    @to_do_list =@user.todo_lessons.sort_by &:created_at

    @featured_topics = TopicGroup.where(featured: true) + Topic.where(featured: true)
    @featured_teachers = Teacher.all.order(score: :desc).limit(5)
    @current_lesson = @user.current_lesson
  end
end
