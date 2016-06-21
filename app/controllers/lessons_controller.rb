class LessonsController < ApplicationController
  before_action :authenticate_user!
  around_filter :user_time_zone, :if => :current_user

  def index
    #Cours reçu par le Prof
    @lesson = Lesson.where(:student => current_user)
    #Cours donné par le Prof
    @lesson += Lesson.where(:teacher => current_user)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @lesson = Lesson.find(params[:id])
    #TODO syntaxe correcte fecth room
    @room = BbbRoom.where(lesson_id = @lesson.id).first
    @recordings = BigbluebuttonRecording.where(room_id = @room.id)
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
    @lesson = Lesson.find(params[:id])
    @hours = ((@lesson.time_end - @lesson.time_start) / 3600).to_i
    @minutes = ((@lesson.time_end - @lesson.time_start) / 60 ) % 60
    zone = current_user.time_zone
    time_start = ActiveSupport::TimeZone[zone].parse(params[:lesson][:time_start])
    time_end = time_start + @hours.hours
    time_end += @minutes.minutes

    @lesson.update_attributes(:time_start => time_start, :time_end => time_end)

    if @lesson.save
      flash[:success] = "La modification s'est correctement déroulée."
      redirect_to dashboard_path and return
    else
      flash[:alert] = "Il y a eu un problème lors de la modification. Veuillez réessayer."
      redirect_to dashboard_path and return
    end
  end

  def require_lesson
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def accept_lesson
    @lesson = Lesson.find(params[:lesson_id])
    @lesson.update_attributes(:status => 2)
    @lesson.save
    body = "#"
    subject = "Le professeur #{@lesson.teacher.email} a accepté votre demande de cours."
    @lesson.student.send_notification(subject, body, @lesson.teacher)
    PrivatePub.publish_to "/lessons/#{@lesson.student_id}", :lesson => @lesson
    flash[:notice] = "Le cours a été accepté."
    redirect_to dashboard_path
  end

  def refuse_lesson
    @lesson = Lesson.find(params[:lesson_id])
    payment_service = MangopayService.new(:user => @lesson.student)
    payment_service.set_session(session)
    return_code = payment_service.make_prepayment_transfer_refund(
        {:lesson_id => @lesson.id})
    if return_code == 1
      flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
      redirect_to dashboard_path and return
    elsif return_code == 0
      @lesson.update_attributes(:status => 4)
      @lesson.save
      body = "#"
      subject = "Le professeur #{@lesson.teacher.email} a refusé votre demande de cours."
      @lesson.student.send_notification(subject, body, @lesson.teacher)
      @lesson.payments.each { |payment| payment.update_attributes(:status => 2) }
      PrivatePub.publish_to "/lessons/#{@lesson.student_id}", :lesson => @lesson
      flash[:notice] = "Le cours a été refusé."
      redirect_to dashboard_path
    else
      flash[:alert] = "Il y a eu une erreur lors du refus. Veuillez réessayer."
      redirect_to dashboard_path and return
    end

  end

  def cancel_lesson
    @lesson = Lesson.find(params[:lesson_id])
    case current_user.id
      when @lesson.teacher_id
        payment_service = MangopayService.new(:user => @lesson.student)
        payment_service.set_session(session)
        return_code = payment_service.make_prepayment_transfer_refund(
            {:lesson_id => @lesson.id})
        if return_code == 1
          flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
          redirect_to dashboard_path and return
        elsif return_code == 0
          @lesson.update_attributes(:status => 3)
          @lesson.save
          @lesson.payments.each { |payment| payment.update_attributes(:status => 2) }
          body = "#"
          subject = "Le professeur #{@lesson.teacher.name} a annulé votre cours."
          @lesson.student.send_notification(subject, body, @lesson.teacher)
          PrivatePub.publish_to "/lessons/#{@lesson.student_id}", :lesson => @lesson
          flash[:notice] = "Le cours a été annulé."
          redirect_to dashboard_path
        else
          flash[:alert] = "Il y a eu une erreur lors de l'annulation. Veuillez réessayer."
          redirect_to dashboard_path and return
        end
      when @lesson.student_id
        if @lesson.pending_teacher?
          payment_service = MangopayService.new(:user => @lesson.student)
          payment_service.set_session(session)
          return_code = payment_service.make_prepayment_transfer_refund(
              {:lesson_id => @lesson.id})
          if return_code == 1
            flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
            redirect_to dashboard_path and return
          elsif return_code == 0
            @lesson.update_attributes(:status => 3)
            @lesson.save
            @lesson.payments.each { |payment| payment.update_attributes(:status => 2) }
            body = "#"
            subject = "L'élève #{@lesson.student.name} a annulé sa demande de cours."
            @lesson.teacher.send_notification(subject, body, @lesson.student)
            PrivatePub.publish_to "/lessons/#{@lesson.teacher_id}", :lesson => @lesson
            flash[:notice] = "Le cours a été annulé."
            redirect_to dashboard_path
          else
            flash[:alert] = "Il y a eu une erreur lors de l'annulation. Veuillez réessayer."
            redirect_to dashboard_path and return
          end
        else
          flash[:alert] = "Le professeur a déjà accepté la demande de cours."
          redirect_to dashboard_path and return
        end
      else
    end
  end

  private

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end

end
