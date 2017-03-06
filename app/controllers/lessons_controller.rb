class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_filter :user_time_zone, :if => :current_user

  def index
    @user = current_user
    @lessons = Lesson.involving(@user).page(params[:page]).per(5)
  end

  def show
    @user = current_user
    @lesson = Lesson.find(params[:id])
    @other = @lesson.other(current_user)
    @room = BbbRoom.where(lesson_id = @lesson.id).first
    @recordings = BigbluebuttonRecording.where(room_id = @room.id) unless @room.nil?
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
      duration = @lesson.duration
      @lesson.time_start =  params[:lesson][:time_start]
      @lesson.time_end = @lesson.time_start + duration.total
      @lesson.status = @lesson.alternate_pending

      if @lesson.save
        flash[:success] = "La modification s'est correctement déroulée."
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
    @lesson = Lesson.find(params[:lesson_id])
    @lesson.update_attributes(:status => 2)
    @lesson.save
    body = "#"
    subject = "Le professeur #{@lesson.teacher.email} a accepté votre demande de cours."
    @lesson.student.send_notification(subject, body, @lesson.teacher)
    PrivatePub.publish_to "/notifications/#{@lesson.student_id}", :lesson => @lesson
    flash[:notice] = "Le cours a été accepté."
    LessonsNotifierWorker.perform() # check if new bbb is needed (right now)
    respond_to do |format|
      format.html {redirect_to dashboard_path}
      format.json {render :json => {:success => "true", 
        :message => "Le cours a été accepté.", :lesson => @lesson}}
    end
  end

  def refuse
    @lesson = Lesson.find(params[:lesson_id])
    @lesson.status = 'refused'
    refuse = RefundLesson.run(user: current_user, lesson: @lesson)

    if refuse.valid?
      flash[:success] = 'Vous avez décliné la demande de cours.'
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
    @lesson = Lesson.find(params[:lesson_id])
    if(@lesson.teacher == current_user || @lesson.time_start > Time.now + 2.days)
      @lesson.status = 'canceled'
      refuse = RefundLesson.run(user: current_user, lesson: @lesson)

      if refuse.valid?
        flash[:success] = 'Vous avez annulé la demande de cours.'
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
    @lesson = Lesson.find(params[:lesson_id])
    pay_teacher = PayTeacher.run(user: current_user, lesson: @lesson)
    if pay_teacher.valid?
      flash[:success] = 'Merci pour votre feedback! Le professeur a été payé.'
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
    @lesson = Lesson.find(params[:lesson_id])
    dispute = DisputeLesson.run(user: current_user, lesson: @lesson)
    if dispute.valid?
      flash[:success] = "Merci pour votre feedback! Un administrateur prendra contact avec vous dans les plus brefs délais."
      respond_to do |format|
        format.html {redirect_to root_path}
        format .json {render :json => {:success => "true", 
          :message => "Merci pour votre feedback! Un administrateur prendra contact avec vous dans les plus brefs délais."}}
      end
    else
      flash[:danger] = "Il y a eu un problème: #{pay_teacher.errors.full_messages.to_sentence} <br />Prenez contact avec l'équipe du site".html_safe
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format .json {render :json => {:success => "false", 
          :message => "Il y a eu un problème. Prenez contact avec l'équipe du site."}}
      end
    end
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
