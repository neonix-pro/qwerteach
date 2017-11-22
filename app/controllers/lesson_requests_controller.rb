class LessonRequestsController < ApplicationController
  class BookWithSelf < StandardError; end

  before_filter :redirect_if_not_logged_in, only: :new
  before_filter :authenticate_user!, except: :new
  before_action :find_users
  before_action :check_mangopay_account, only: :payment
  before_action :set_lesson, expect: [:topics, :levels, :calculate]
  before_filter :user_time_zone, :if => :current_user
  before_action :check_users_different, only: [:new, :create]

  rescue_from BookWithSelf, with: :dont_book_with_self

  after_filter { flash.discard if request.xhr? }

  def dont_book_with_self(exception)
    flash[:notice]= "Vous ne pouvez pas réserver de cours avec vous-même!"
    flash_to_headers
    respond_to do |format|
      format.js {redirect_to dashboard_path}
      format.json {render :json => {:message => "Vous ne pouvez pas réserver de cours avec vous-mêmes."}}
    end
  end

  def new
    @lesson_request = @lesson.present? ? CreateLessonRequest.from_lesson(@lesson) : CreateLessonRequest.new
    @offers = @teacher.offers_by_level_code
    @booking_delay = @teacher.booking_delay
  end

  def create
    Lesson.drafts(current_user).destroy_all
    duration_free_lesson
    saving = CreateLessonRequest.run(request_params)
    if saving.valid?
      @lesson = saving.result
      if @lesson.free_lesson
        if @user.can_book_free_lesson_with?(@teacher)
          @lesson.save
          NotificationsMailer.notify_teacher_about_booking(@lesson).deliver_later
          notify_teacher("#{student.name} vous adresse une demande de cours. " + link_to('Détails', lessons_path))
          respond_to do |format|
            format.js {render 'finish'}
            format.json {render :json => {:message => "finish"}}
          end
        else
          redirect_to new_user_lesson_request_path(@teacher), danger: "Vous ne pouvez pas réserver de cours gratuit avec ce professeur"
        end
      elsif check_mangopay_account
        creation = Mango::CreateCardRegistration.run(user: current_user)
        if !creation.valid?
          respond_to do |format|
            format.js {render 'errors', :layout=>false, locals: {object: creation}}
            format.json {render :json => {:message => "false"}}
          end
        else
          @card_registration = creation.result
          respond_to do |format|
            format.js {render 'payment_method'}
            format.json {render :json => {:message => "true", :card_registration => @card_registration, :user_cards => @user.mangopay.cards}}
          end
        end
      end
    else
      respond_to do |format|
          format.js {render 'errors', :layout=>false, locals: {object: saving}}
          format.json {render :json => {:message => "false"}}
        end
    end
  end

  def payment
    render 'new' and return if @lesson.nil?
    PayLesson.run(controller: self, lesson: @lesson)
  end

  def credit_card_process
    processing = PayLessonWithCard.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      send_notification
      tracker do |t|
        t.google_analytics :send, { type: 'event', category: 'Booking', action: 'created_by_student', label: "Prof id: #{@teacher.id}" }
        t.google_analytics :send, { type: 'event', category: 'Payment', action: 'Booking payment', label: "Credit Card", value: @lesson.price }
      end
      respond_to do |format|
        format.html {render 'finish'}
        format.json {render :json => {:success => "true"}}
      end
    else
      respond_to do |format|
        format.html {redirect_to new_user_lesson_request_path(@teacher), notice: t('notice.booking_error')}
        format.json {render :json => {:success => "false"}}
      end
    end
  end

  def bancontact_process
    processing = PayLessonByBancontact.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      send_notification
      tracker do |t|
        t.google_analytics :send, { type: 'event', category: 'Booking', action: 'created_by_student', label: "Prof id: #{@teacher.id}" }
        t.google_analytics :send, { type: 'event', category: 'Payment', action: 'Booking payment', label: "Bancontact", value: @lesson.price }
      end
      respond_to do |format|
        #format.html {redirect_to lessons_path, notice: t('notice.booking_success')}
        format.html {render 'finish'}
        format.json {render :json => {:success => "true"}}
      end
    else
      respond_to do |format|
        format.html {redirect_to new_user_lesson_request_path(@teacher), notice: t('notice.booking_error')}
        format.json {render :json => {:success => "false"}}
      end
    end
  end

  def finish

  end

  def topics
    @topics = @teacher.offers.includes(:topic).where(topics: params.slice(:topic_group_id)).uniq
      .pluck_to_hash('topics.id as id', 'topics.title as title')
    render :json => {:topics => @topics}
  end

  def levels
    @levels = @teacher.offers.includes(offer_prices: :level).where(topic_id: params[:topic_id]).uniq
      .pluck_to_hash('levels.id as id', 'levels.fr as title')
    render :json => {:levels => @levels}
  end

  def calculate
    @calc = CalculateLessonPrice.run(calculating_params)
    if @calc.valid?
      render :json => {:price => @calc.result}
    else
      render :json => {:error => @calc.errors.full_messages.first}
    end
  end

  def create_account
    saving = Mango::SaveAccount.run( params.fetch(:account).permit!.merge(user: current_user) )
    if saving.valid?
      @card_registration = Mango::CreateCardRegistration.run(user: current_user).result
      render 'payment_method'
    else
      render 'errors', :layout=>false, locals: {object: saving}
    end
  end

  private

  def find_users
    @user = current_user
    @teacher = Teacher.find(params[:user_id])
  end

  def set_lesson
    @lesson = Lesson.drafts(current_user).first.try(:restore)
    if !@lesson.nil? && @lesson.teacher.id.to_s == params[:user_id].to_s
      @lesson
    else
      @lesson = nil
    end
  end

  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end, :free_lesson).merge(:student_id => current_user.id)
  end

  def request_params
    params.require(:request).permit(:student_id, :level_id, :topic_id, :time_start, :hours, :minutes, :free_lesson, 'start_at(4i)').merge({
      :student_id => current_user.id,
      :teacher_id => @teacher.id
    })
  end

  def calculating_params
    params.slice(:hours, :minutes, :topic_id, :level_id).merge(teacher_id: @teacher.id)
  end

  def check_mangopay_account
    return true if current_user.mango_id.present?
    @account = Mango::SaveAccount.new(user: current_user, first_name: current_user.firstname, last_name: current_user.lastname)
    respond_to do |format|
      format.js {render 'mango_account', :layout=>false}
      format.json {render :json => {:message => "no account"}}
    end and return false
  end
  
  def send_notification
    Pusher.notify(["#{@lesson.teacher.id}"], {fcm: {notification: {body: "#{@lesson.student.name} vous adresse une demande de cours.",
        icon: 'androidlogo', click_action: "MY_LESSONS"}}})
  end

  def redirect_if_not_logged_in
    unless current_user
      session[:user_redirect_to]= request.original_url
      @teacher = Teacher.find(params[:user_id])
      render 'sign_up_booking'
    end
  end

  def duration_free_lesson
    if params[:request][:free_lesson] == '1'
      params[:request][:hours]=0
      params[:request][:minutes]=30
    end
  end

  def check_users_different
    raise BookWithSelf unless !current_user || User.find(params[:user_id]) != current_user
  end

end
