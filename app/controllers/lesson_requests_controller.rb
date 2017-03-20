class LessonRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_action :find_users
  before_action :check_mangopay_account, only: :payment
  before_action :set_lesson, expect: [:topics, :levels, :calculate]
  before_filter :user_time_zone, :if => :current_user

  after_filter { flash.discard if request.xhr? }

  def new
    @free_lessons = @user.free_lessons_with(@teacher)
    @lesson_request = @lesson.present? ? CreateLessonRequest.from_lesson(@lesson) : CreateLessonRequest.new
    @offers = @teacher.offers_by_level_code
  end

  def create
    Lesson.drafts(current_user).destroy_all
    @free_lessons = @user.free_lessons_with(@teacher)
    saving = CreateLessonRequest.run(request_params)
    if saving.valid?
      @lesson = saving.result
      if @lesson.free_lesson
        @lesson.save
        respond_to do |format|
          format.js {render 'finish'}
          format.json {render :json => {:message => "finish"}}
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

    case params[:mode]

      when 'transfert'
        paying = PayLessonByTransfert.run(user: current_user, lesson: @lesson)
        if paying.valid?
          respond_to do |format|
            format.js {render 'finish', :layout => false}
            format.json {render :json => {:message => "finish"}}
            format.html {redirect_to lessons_path}
          end and return
        else
          @card_registration = Mango::CreateCardRegistration.run(user: current_user).result
          respond_to do |format|
            format.js {render 'errors', :layout=>false, locals: {object: paying}}
            format.json {render :json => {:message => "errors"}}
          end
        end

      when 'bancontact'
        return_url = bancontact_process_user_lesson_requests_url(@teacher)
        payin = Mango::PayinBancontact.run(user: current_user, amount: @lesson.price,
          return_url: return_url, wallet: 'transaction')
        if payin.valid?
          respond_to do |format|
            format.js {render js: "window.location = '#{payin.result.redirect_url}'"}
            format.json {render :json => {:message => "result", :url => payin.result.redirect_url}}
          end and return
        else
          respond_to do |format|
            format.js {render 'errors', :layout=>false, locals: {object: payin}}
            format.json {render :json => {:message => "errors"}}
          end
        end

      when 'cd'
        return_url = credit_card_process_user_lesson_requests_url(@teacher)
        payin = Mango::PayinCreditCard.run({user: current_user, amount: @lesson.price,
          card_id: params[:card_id], return_url: return_url, wallet: 'transaction'})

        if payin.valid?
          result = payin.result
          if result.secure_mode_redirect_url.present?
            respond_to do |format|
              format.js {render js: "window.location = '#{result.secure_mode_redirect_url}'"}
              format.json {render :json => {:message => "result", :url => result.secure_mode_redirect_url}}
            end and return
          else
            paying = PayLessonWithCard.run(user: current_user, lesson: @lesson, transaction_id: result.id)
            if !paying.valid?
              respond_to do |format|
                format.js {render 'errors', :layout=>false, locals: {object: paying}}
                format.json {render :json => {:message => "errors"}}
              end
            else
              respond_to do |format|
                format.js {render 'finish', :layout => false}
                format.json {render :json => {:message => "finish"}}
              end
            end
          end
        else
          respond_to do |format|
            format.js {render 'errors', :layout=>false, locals: {object: payin}}
            format.json {render :json => {:message => "errors"}}
          end
        end

    end
  end

  def credit_card_process
    processing = PayLessonWithCard.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      respond_to do |format|
        format.html {redirect_to lessons_path, notice: t('notice.booking_success')}
        format.json {render :json => {:success => "true"}}
      end
    else
      respond_to do |format|
        format.html {redirect_to user_path(@lesson.teacher), notice: t('notice.booking_error')}
        format.json {render :json => {:success => "false"}}
      end
    end
  end

  def bancontact_process
    processing = PayLessonByBancontact.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      respond_to do |format|
        format.html {redirect_to lessons_path, notice: t('notice.booking_success')}
        format.json {render :json => {:success => "true"}}
      end
    else
      respond_to do |format|
        format.html {redirect_to user_path(@lesson.teacher), notice: t('notice.booking_error')}
        format.json {render :json => {:success => "false"}}
      end
    end
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
      render json: {price: @calc.result}
    else
      render json: {error: @calc.errors.full_messages.first}
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


end
