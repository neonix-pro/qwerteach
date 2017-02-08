class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_filter :user_time_zone, :if => :current_user
  after_action :email_user, only: [:update, :accept, :refuse, :cancel, :dispute, :pay_teacher]

  def index
    @user = current_user
    @lessons = Lesson.involving(@user).page(params[:page]).per(5)
    if @lessons.empty?
      @teachers = Teacher.all.order(score: :desc).limit(5)
    end
  end

  def show
    @user = current_user
    @lesson = Lesson.find(params[:id])
    @other = @lesson.other(current_user)
    @room = BbbRoom.where(lesson_id = @lesson.id).first
    @recordings = @lesson.bbb_room.recordings
    @todo = @lesson.todo(@user)
  end

  def new
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def edit
    @lesson = Lesson.find(params[:id])
    @hours = ((@lesson.time_end - @lesson.time_start) / 3600).to_i
    @minutes = ((@lesson.time_end - @lesson.time_start) / 60 ) % 60
  end

  def update
    # reschedule a lesson
    @lesson = Lesson.find(params[:id])
    if @lesson.pending_any?
      @lesson = Lesson.find(params[:id])
      duration = @lesson.duration
      @lesson.time_start =  params[:lesson][:time_start]
      @lesson.time_end = @lesson.time_start + duration.total
      @lesson.status = @lesson.alternate_pending
      @notification_text = "#{@lesson.other(current_user).name} a modifié votre demande pour le cours ##{@lesson.id}."
      @lesson.other(current_user).send_notification(@notification_text, '#', @lesson.teacher)
      if @lesson.save
        flash[:success] = "La modification s'est correctement déroulée."
        redirect_to lessons_path and return
      else
        flash[:danger] = "Il y a eu un problème lors de la modification. Veuillez réessayer."
        redirect_to dashboard_path and return
      end
    end
  end

  def accept
    @lesson = Lesson.find(params[:lesson_id])
    @lesson.update_attributes(:status => 2)
    @lesson.save
    body = "#"
    if @lesson.teacher == current_user
      @notification_text = "Le professeur #{@lesson.teacher.name} a accepté votre demande de cours."
    else
      @notification_text = "#{@lesson.student.name} a accepté la demande de cours pour le cours ##{@lesson.id}."
    end
    @lesson.other(current_user).send_notification(@notification_text, body, @lesson.teacher)
    PrivatePub.publish_to "/notifications/#{@lesson.student_id}", :lesson => @lesson
    flash[:notice] = "Le cours a été accepté."
    LessonsNotifierWorker.perform() # check if new bbb is needed (right now)
    redirect_to dashboard_path
  end

  def refuse
    @lesson = Lesson.find(params[:lesson_id])
    @lesson.status = 'refused'
    refuse = RefundLesson.run(user: current_user, lesson: @lesson)

    if refuse.valid?
      body = "#"
      @notification_text = "#{current_user.name} a refusé votre demande de cours."
      @lesson.other(current_user).send_notification(@notification_text, body, current_user)
      flash[:success] = 'Vous avez décliné la demande de cours.'
      redirect_to lessons_path
    else
      flash[:danger] = "Il y a eu un problème: #{refuse.errors.full_messages.to_sentence} <br />Le cours n'a pas été refusé".html_safe
      redirect_to lessons_path
    end
  end

  def cancel
    @lesson = Lesson.find(params[:lesson_id])
    if(@lesson.teacher == current_user || @lesson.time_start > Time.now + 2.days)
      @lesson.status = 'canceled'
      refuse = RefundLesson.run(user: current_user, lesson: @lesson)

      if refuse.valid?
        body = "#"
        @notification_text = "#{current_user.name} a annulé la demande de cours."
        @lesson.other(current_user).send_notification(@notification_text, body, current_user)
        flash[:success] = 'Vous avez annulé la demande de cours.'
        redirect_to lessons_path
      else
        flash[:danger] = "Il y a eu un problème: #{refuse.errors.full_messages.to_sentence}.<br /> Le cours n'a pas été annulé.".html_safe
        redirect_to lessons_path
      end
    else
      flash[:danger]="Seul le professeur peut annuler un cours moins de 48h à l'avance."
      redirect_to lessons_path
    end
  end

  def pay_teacher
    @lesson = Lesson.find(params[:lesson_id])
    pay_teacher = PayTeacher.run(user: current_user, lesson: @lesson)
    if pay_teacher.valid?
      @notification_text = "Le payement de votre cours avec #{current_user.name} a été débloqué!"
      @lesson.other(current_user).send_notification(@notification_text, '#', current_user)
      flash[:success] = 'Merci pour votre feedback! Le professeur a été payé.'
      redirect_to lessons_path
    else
      flash[:danger] = "Il y a eu un problème: #{pay_teacher.errors.full_messages.to_sentence} <br />Nous n'avons pas pu procéder au payement du professeur".html_safe
      redirect_to lessons_path
    end
  end

  def dispute
    @lesson = Lesson.find(params[:lesson_id])
    dispute = DisputeLesson.run(user: current_user, lesson: @lesson)
    if dispute.valid?
      @notification_text = "#{current_user.name} a déclaré un litige sur le cours ##{@leson.id}. Le payement est suspendu, un administrateur prendra contact avec vous sous peu."
      @lesson.other(current_user).send_notification(@notification_text, '#', current_user)
      flash[:success] = "Merci pour votre feedback! Un administrateur prendra contact avec vous dans le splus brefs délais."
      redirect_to root_path
    else
      flash[:danger] = "Il y a eu un problème: #{pay_teacher.errors.full_messages.to_sentence} <br />Prenez contact avec l'équipe du site".html_safe
      redirect_to lessons_path
    end
  end

  private

  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

  def email_user
    @other = @lesson.other(current_user)
    LessonMailer.update_lesson(@other, @lesson, @notification_text).deliver
  end
end
