class RequireLessonController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!

  steps :choose_lesson, :payment, :transfert, :bancontact, :cd

  def show
    @teacher = params[:user_id]
    @user = current_user
    case step
      when :choose_lesson
        @kal = 'grosse'
        @lesson = Lesson.new
      when :payment
      when :transfert
      when :bancontact
      when :cd

    end
    render_wizard
  end

  def update
    @lesson = Lesson.new
    case step
      when :choose_lesson
        session[:lesson] = {}
        session[:lesson] = params[:lesson]
        jump_to(:payment)
      when :payment
        mode = params[:mode]
        jump_to(mode)
      when :transfert
      when :bancontact
      when :cd
      else
        @lesson.update(session[:lesson])
        if @lesson.save
        end
        session.delete(:lesson)

    end
    logger.debug('SESSION = '+ session[:lesson].to_s)
    render_wizard
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
