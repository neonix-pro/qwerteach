class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_lesson_infos, except: [:new, :index]
  before_filter :user_time_zone, :if => :current_user
  # needs to check that everything went OK before sending mail!
  #after_action :email_user, only: [:update, :accept, :refuse, :cancel, :dispute, :pay_teacher]

  def index
    @user = current_user
    @lessons = Lesson.involving(@user).page(params[:page]).per(5)
    if @lessons.empty?
      @teachers = Teacher.all.order(score: :desc).limit(5)
    end
  end

  def show
    @room = BbbRoom.where(lesson_id = @lesson.id).first
    @recordings = @lesson.bbb_room.recordings
    @todo = @lesson.todo(@user)
  end

  def new
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def edit
    @hours = ((@lesson.time_end - @lesson.time_start) / 3600).to_i
    @minutes = ((@lesson.time_end - @lesson.time_start) / 60 ) % 60
  end

  def update
    # reschedule a lesson
    if @lesson.pending_any?
      duration = @lesson.duration
      @lesson.time_start =  params[:lesson][:time_start]
      @lesson.time_end = @lesson.time_start + duration.total
      @lesson.status = @lesson.alternate_pending
      @notification_text = "#{@other.name} a modifié votre demande pour le cours ##{@lesson.id}."
      @other.send_notification(@notification_text, '#', @user, @lesson)
      if @lesson.save
        flash[:success] = "La modification s'est correctement déroulée."
        email_user
        redirect_to lessons_path and return
      else
        flash[:danger] = "Il y a eu un problème lors de la modification. Veuillez réessayer."
        redirect_to dashboard_path and return
      end
    end
  end

  def accept
    @lesson.update_attributes(:status => 2)
    @lesson.save
    body = "#"
    if @lesson.is_teacher?(@user)
      @notification_text = "Le professeur #{@lesson.teacher.name} a accepté votre demande de cours."
    else
      @notification_text = "#{@lesson.student.name} a accepté la demande de cours pour le cours ##{@lesson.id}."
    end
    @other.send_notification(@notification_text, body, @user, @lesson)
    PrivatePub.publish_to "/notifications/#{@other.id}", :lesson => @lesson # ???
    flash[:notice] = "Le cours a été accepté."
    LessonsNotifierWorker.perform() # check if new bbb is needed (right now)
    email_user
    redirect_to dashboard_path
  end

  def refuse
    @lesson.status = 'refused'
    refuse = RefundLesson.run(user: @user, lesson: @lesson)

    if refuse.valid?
      body = "#"
      @notification_text = "#{@user.name} a refusé votre demande de cours."
      @other.send_notification(@notification_text, body, @user, @lesson)
      flash[:success] = 'Vous avez décliné la demande de cours.'
      email_user
      redirect_to lessons_path
    else
      flash[:danger] = "Il y a eu un problème: #{refuse.errors.full_messages.to_sentence} <br />Le cours n'a pas été refusé".html_safe
      redirect_to lessons_path
    end
  end

  def cancel
    #TO DO: refactor to model
    if @lesson.can_cancel?(@user)
      @lesson.status = 'canceled'
      refuse = RefundLesson.run(user: @user, lesson: @lesson)
      if refuse.valid?
        body = "#"
        @notification_text = "#{@user.name} a annulé la demande de cours."
        @other.send_notification(@notification_text, body, @user, @lesson)
        flash[:success] = 'Vous avez annulé la demande de cours.'
        email_user
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
    pay_teacher = PayTeacher.run(user: @user, lesson: @lesson)
    if pay_teacher.valid?
      @notification_text = "Le payement de votre cours avec #{@user.name} a été débloqué!"
      @other.send_notification(@notification_text, '#', @user, @lesson)
      flash[:success] = 'Merci pour votre feedback! Le professeur a été payé.'
      email_user
      redirect_to lessons_path
    else
      flash[:danger] = "Il y a eu un problème: #{pay_teacher.errors.full_messages.to_sentence} <br />Nous n'avons pas pu procéder au payement du professeur".html_safe
      redirect_to lessons_path
    end
  end

  def dispute
    dispute = DisputeLesson.run(user: @user, lesson: @lesson)
    if dispute.valid?
      @notification_text = "#{@user.name} a déclaré un litige sur le cours ##{@leson.id}. Le payement est suspendu, un administrateur prendra contact avec vous sous peu."
      @other.send_notification(@notification_text, '#', @user, @lesson)
      flash[:success] = "Merci pour votre feedback! Un administrateur prendra contact avec vous dans le splus brefs délais."
      email_user
      redirect_to root_path
    else
      flash[:danger] = "Il y a eu un problème: #{dispute.errors.full_messages.to_sentence} <br />Prenez contact avec l'équipe du site".html_safe
      redirect_to lessons_path
    end
  end

  private

  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

  def email_user
    LessonMailer.update_lesson(@other, @lesson, @notification_text).deliver
  end

  def find_lesson_infos
    @user = current_user
    @lesson = params[:id].nil? ? Lesson.find(params[:lesson_id]) : Lesson.find(params[:id])
    @other = @lesson.other(@user)
  end
end
