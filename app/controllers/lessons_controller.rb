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
    @recordings = @lesson.bbb_room.recordings unless @lesson.bbb_room.nil?
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
        respond_to do |format|
          format.html {redirect_to lessons_path}
          format.json {render :json => {:success => "true", :message => "La modification s'est correctement déroulée."}}
        end and return
      else
        flash[:alert] = "Il y a eu un problème lors de la modification. Veuillez réessayer."
        respond_to do |format|
          format.html {redirect_to dashboard_path}
          format.json {render :json => {:success => "error", :message => "Il y a eu un problème lors de la modification. Veuillez réessayer."}}
        end and return
      end
    end
  end

  def accept
    if @lesson.is_student?(current_user) and !@lesson.paid? and !@lesson.prepaid? and !@lesson.pay_afterwards
      redirect_to new_lesson_payment_path(@lesson) and return
    end

    accepting = AcceptLesson.run(lesson: @lesson, user: current_user)
    if accepting.valid?
      respond_to do |format|
        format.html {redirect_to dashboard_path, notice: "Le cours a été accepté."}
        format.json {render :json => {:success => "true", :message => "Le cours a été accepté.", :lesson => @lesson}}
      end
    else
      respond_to do |format|
        format.html {redirect_to dashboard_path, flash: {danger: accepting.errors.full_messages.first}}
        format.json {render :json => {:success => "false", :message => accepting.errors.full_messages.first, :lesson => @lesson}}
      end
    end

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
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "true", 
          :message => "Vous avez décliné la demande de cours.", :lesson => @lesson}}
      end
    else
      flash[:danger] = "Il y a eu un problème: #{refuse.errors.full_messages.to_sentence} <br />Le cours n'a pas été refusé".html_safe
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "false", 
          :message => "Il y a eu un problème. Le cours n'a pas été refusé."}}
      end
    end
  end

  def cancel
    if @lesson.can_cancel?(@user)
      status = @lesson.status
      @lesson.status = 'canceled'
      refuse = RefundLesson.run(user: @user, lesson: @lesson)
      if refuse.valid?
        body = "#"
        if statuts == 'created'
          @notification_text = "#{@user.name} a annulé le cours."
        else
          @notification_text = "#{@user.name} a annulé la demande de cours."
        end

        @other.send_notification(@notification_text, body, @user, @lesson)
        flash[:success] = 'Vous avez annulé la demande de cours.'
        email_user
        respond_to do |format|
          format.html {redirect_to lessons_path}
          format.json {render :json => {:success => "true", 
            :message => "Vous avez annulé la demande de cours.", :lesson => @lesson}}
        end
      else
        flash[:danger] = "Il y a eu un problème: #{refuse.errors.full_messages.to_sentence}.<br /> Le cours n'a pas été annulé.".html_safe
        respond_to do |format|
          format.html {redirect_to lessons_path}
          format.json {render :json => {:success => "false", 
            :message => "Il y a eu un problème. Le cours n'a pas été annulé."}}
        end
      end
    else
      flash[:danger]="Seul le professeur peut annuler un cours moins de 48h à l'avance."
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "false", 
          :message => "Seul le professeur peut annuler un cours moins de 48h à l'avance."}}
      end
    end
  end

  def pay_teacher
    unless @lesson.prepaid?
      redirect_to new_lesson_payment_path(@lesson) and return
    end
    pay_teacher = PayTeacher.run(user: @user, lesson: @lesson)
    if pay_teacher.valid?
      @notification_text = "Le payement de votre cours avec #{@user.name} a été débloqué!"
      @other.send_notification(@notification_text, '#', @user, @lesson)
      flash[:success] = 'Merci pour votre feedback! Le professeur a été payé.'
      email_user
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "true", :message => "Merci pour votre feedback! Le professeur a été payé."}}
      end
    else
      flash[:danger] = "Il y a eu un problème: #{pay_teacher.errors.full_messages.to_sentence} <br />Nous n'avons pas pu procéder au payement du professeur".html_safe
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "false", :message => "Il y a eu un problème. Nous n'avons pas pu procéder au payement du professeur"}}
      end
    end
  end

  def dispute
    dispute = DisputeLesson.run(user: @user, lesson: @lesson)
    if dispute.valid?
      @notification_text = "#{@user.name} a déclaré un litige sur le cours ##{@lesson.id}. Le payement est suspendu, un administrateur prendra contact avec vous sous peu."
      @other.send_notification(@notification_text, '#', @user, @lesson)
      flash[:success] = "Merci pour votre feedback! Un administrateur prendra contact avec vous dans le splus brefs délais."
      email_user
      respond_to do |format|
        format.html {redirect_to root_path}
        format.json {render :json => {:success => "true", 
          :message => "Merci pour votre feedback! Un administrateur prendra contact avec vous dans les plus brefs délais."}}
      end
    else
      flash[:danger] = "Il y a eu un problème: #{dispute.errors.full_messages.to_sentence} <br />Prenez contact avec l'équipe du site".html_safe
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "false", 
          :message => "Il y a eu un problème. Prenez contact avec l'équipe du site."}}
      end
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
