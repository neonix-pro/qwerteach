class LessonsController < ApplicationController
  before_action :authenticate_user!

  def new
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def require_lesson
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end)
  end
end
