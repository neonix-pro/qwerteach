class LessonsController < ApplicationController
  load_and_authorize_resource except: :calendar_index
  before_action :authenticate_user!
  before_action :find_lesson_infos, except: [:new, :index, :calendar_index, :index_pagination]
  before_filter :user_time_zone, :if => :current_user
  before_filter :check_has_payments, only: :dispute
  before_action :filter_options, only: [:index, :index_pagination]
  #needs to check that everything went OK before sending mail!
  #after_action :email_user, only: [:update, :accept, :refuse, :cancel, :dispute, :pay_teacher]

  def index
    @user = current_user
    @planned_lessons = @user.planned_lessons.page(1).per(6)
    @pending_lessons = @user.pending_lessons.page(1).per(6)
    @history_lessons = @user.history_lessons.page(1).per(12)
    if @planned_lessons.empty? && @pending_lessons.empty?
      @teachers = Teacher.all.order(score: :desc).limit(4)
    end
    @number_of_pending_lessons = @user.pending_me_lessons.count

  end

  def index_pagination
    @user = current_user
    case params[:lesson_type]
      when 'planned'
        @planned_lessons = Lesson.involving(@user).created.future.page(params[:page]).per(6)
        respond_to do |format|
          format.json{ render :json => {:upcoming_lessons => @planned_lessons} }
          format.js
        end
      when 'pending'
        @pending_lessons = Lesson.involving(@user).pending.future.page(params[:page]).per(6)
        respond_to do |format|
          format.json{ render :json => {:to_do_list => @pending_lessons} }
          format.js
        end
      when 'history'
        @history_lessons = Lesson.involving(@user).page(params[:page]).per(12)
        search_history
        respond_to do |format|
          format.json{ render :json => {:past_lessons => @history_lessons}}
          format.js
        end
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

  def calendar_index
    @user = params[:id].nil? ? current_user : User.find(params[:id])
    @lessons = Lesson.involving(@user).where(status: 2).where("time_start > '#{params[:start]}' AND time_end < '#{params[:end]}'")
    respond_to do |format|
      format.json {render json: @lessons}
    end
  end

  def update
    # reschedule a lesson
    if @lesson.pending_any?
      duration = @lesson.duration
      @lesson.time_start =  params[:lesson][:time_start]
      @lesson.time_end = @lesson.time_start + duration.total
      @lesson.status = @lesson.alternate_pending
      if @lesson.save
        flash[:success] = "La modification s'est correctement déroulée."
        if @lesson.is_teacher?(current_user)
          LessonNotificationsJob.perform_async(:notify_student_about_reschedule_lesson, @lesson.id)
          Pusher.notify(["#{@lesson.student.id}"], {fcm: {notification: {body: "#{@lesson.teacher.name} a déplacé le votre demande de cours. Veuillez confirmer le nouvel horaire.", 
            icon: 'androidlogo', click_action: "MY_LESSONS"}}})
        else
          LessonNotificationsJob.perform_async(:notify_teacher_about_reschedule_lesson, @lesson.id)
          Pusher.notify(["#{@lesson.teacher.id}"], {fcm: {notification: {body: "#{@lesson.student.name} a déplacé le votre demande de cours. Veuillez confirmer le nouvel horaire.", 
            icon: 'androidlogo', click_action: "MY_LESSONS"}}})
        end
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
      category = @lesson.free_lesson? ? 'Free Booking' : 'Booking'
      action = @lesson.is_student?(current_user) ? 'accepted_by_student' : 'accepted_by_teacher'
      #ga_track_event(category, action, "Teacher id: #{@lesson.teacher.id}")
      respond_to do |format|
        format.html {redirect_to dashboard_path, notice: "Le cours a été accepté."}
        format.json {render :json => {:success => "true", :message => "Le cours a été accepté."}}
      end
    else
      respond_to do |format|
        format.html {redirect_to dashboard_path, flash: {danger: accepting.errors.full_messages.first}}
        format.json {render :json => {:success => "false", :message => accepting.errors.full_messages.first}}
      end
    end

  end

  def refuse
    @lesson.status = 'refused'
    refuse = RefundLesson.run(user: @user, lesson: @lesson)
    if refuse.valid?
      body = "#"
      flash[:success] = 'Vous avez décliné la demande de cours.'
      category = @lesson.free_lesson? ? 'Free Booking' : 'Booking'
      action = @lesson.is_student?(current_user) ? 'refused_by_student' : 'refused_by_teacher'
      #ga_track_event(category, action, "Teacher id: #{@lesson.teacher.id}")
      respond_to do |format|
        format.html {redirect_to lessons_path}
        format.json {render :json => {:success => "true", 
          :message => "Vous avez décliné la demande de cours."}}
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
        category = @lesson.free_lesson? ? 'Free Booking' : 'Booking'
        action = @lesson.is_student?(current_user) ? 'canceled_by_student' : 'canceled_by_teacher'
        #ga_track_event(category, action, "Teacher id: #{@lesson.teacher.id}")
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
    unless @lesson.prepaid?
      redirect_to new_lesson_payment_path(@lesson) and return
    end
    pay_teacher = PayTeacher.run(user: @user, lesson: @lesson)
    if pay_teacher.valid?
      flash[:success] = 'Merci pour votre feedback! Le professeur a été payé.'
      respond_to do |format|
        format.html {
          if @lesson.review_needed?(current_user)
            redirect_to new_user_review_path(@lesson.teacher)
          else
            redirect_to lessons_path
          end
        }
        format.json {render :json => {:success => "true", :message => "Merci pour votre feedback! Le professeur a été payé.", 
          :review_needed => @lesson.review_needed?(current_user)}}
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
      flash[:danger] = "Merci pour votre feedback! Un administrateur examine prendra contact avec vous dans les plus brefs délais."
      if @lesson.is_teacher?(current_user)
        Pusher.notify(["#{@lesson.student.id}"], {fcm: {notification: {body: @notification_text, icon: 'androidlogo', click_action: "MY_NOTIFICATIONS"}}})
      else
        Pusher.notify(["#{@lesson.teacher.id}"], {fcm: {notification: {body: @notification_text, icon: 'androidlogo', click_action: "MY_NOTIFICATIONS"}}})
      end
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

  def check_has_payments
    if @lesson.payments.empty?
      flash[:danger]= 'Vous ne pouvez pas déclarer de litige sur un cours non pré-payé. Veuillez contacter les administrateur du site si le cours doit être annulé.'
      redirect_to dashboard_path
    end
  end

  def search_history
    case params[:filter]
      when 'is_teacher'
        @history_lessons = Lesson.involving(@user).not.is_student(@user).page(params[:page]).per(12)
      when 'is_student'
        logger.debug('------'*10)
        @history_lessons = Lesson.involving(@user).is_student(@user).page(params[:page]).per(12)
      when 'expired'
        @history_lessons = Lesson.involving(@user).expired.page(params[:page]).per(12)
      when 'canceled'
        @history_lessons = Lesson.involving(@user).canceled.page(params[:page]).per(12)
      when 'refused'
        @history_lessons = Lesson.involving(@user).refused.page(params[:page]).per(12)
      when 'payment_locked'
        @history_lessons = Lesson.involving(@user).locked.page(params[:page]).per(12)
      when 'is_unpaid'
        @history_lessons = Lesson.involving(@user).needs_pay.page(params[:page]).per(12)
      else
        @history_lessons = Lesson.involving(@user).page(params[:page]).per(12)
    end
  end

  def filter_options
    @filter_options = {"Tous": 'all' , "Où j'étais prof": 'is_teacher', "Où j'étais élève": 'is_student', "Expirés": 'expired',
                       "Annulés": 'canceld', "Refusés": 'refused', "Paiement détenur par Qwerteach": 'payment_locked',
                       "Paiement non effectué par l'élève": 'is_unpaid'}
  end
  
end
