class LessonsController < ApplicationController
  before_action :authenticate_user!

  def new
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def create
    @student_id = current_user.id
    @lesson = Lesson.new(lesson_params)
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to root_path, notice: 'Lesson was successfully required.' }
      end
    end
  end

  def require_lesson
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end
end
