class RequestLessonController < ApplicationController
  before_filter :authenticate_user!
  before_action :find_users
  before_action :check_mangopay_account, only: :payment
  before_action :set_lession, expect: [:topics, :levels, :calculate]

  after_filter { flash.discard if request.xhr? }

  def new
    @free_lessons = @user.free_lessons_with(@teacher)
    @lession_request = @lesson.present? ? CreateLessonRequest.from_lesson(@lesson) : CreateLessonRequest.new
  end

  def create
    Lesson.drafts(current_user).destroy_all
    @free_lessons = @user.free_lessons_with(@teacher)
    saving = CreateLessonRequest.run(request_params)
    if saving.valid?
      @lesson = saving.result
      if @lesson.free_lesson
        @lesson.save
        render 'finish'
      elsif check_mangopay_account
        creation = Mango::CreateCardRegistration.run(user: current_user)
        if !creation.valid?
          render 'errors', :layout=>false, locals: {object: creation}
        else
          @card_registration = creation.result
          render 'payment_method'
        end
      end
    else
      render 'errors', :layout=>false, locals: {object: saving}
    end
  end

  def payment
    render 'new' and return if @lesson.nil?

    case params[:mode]

      when 'transfert'
        paying = PayLessonByTransfert.run(user: current_user, lesson: @lesson)
        if paying.valid?
          render 'finish', :layout => false
        else
          @card_registration = Mango::CreateCardRegistration.run(user: current_user).result
          render 'errors', :layout=>false, locals: {object: paying}
        end

      when 'bancontact'
        return_url = bancontact_process_user_request_lesson_index_url(@teacher)
        payin = Mango::PayinBancontact.run(user: current_user, amount: @lesson.price,
          return_url: return_url, wallet: 'transaction')
        if payin.valid?
          render js: "window.location = '#{payin.result.redirect_url}'" and return
        else
          render 'errors', :layout=>false, locals: {object: payin}
        end

      when 'cd'
        return_url = credit_card_process_user_request_lesson_index_url(@teacher)
        payin = Mango::PayinCreditCard.run({user: current_user, amount: @lesson.price,
          card_id: params[:card_id], return_url: return_url, wallet: 'transaction'})

        if payin.valid?
          result = payin.result
          if result.secure_mode == 'FORCE' and result.secure_mode_redirect_url.present?
            render js: "window.location = '#{result.secure_mode_redirect_url}'" and return
          else
            paying = PayLessonWithCard.run(user: current_user, lesson: @lesson, transaction_id: result.id)
            if !paying.valid?
              render 'errors', :layout=>false, locals: {object: paying}
            else
              render 'finish', :layout => false
            end
          end
        else
          render 'errors', :layout=>false, locals: {object: payin}
        end

    end
  end

  def credit_card_process
    processing = PayLessonWithCard.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      redirect_to lessons_path, notice: t('notice.booking_success')
    else
      redirect_to user_path(@lesson.teacher), notice: t('notice.booking_error')
    end
  end

  def bancontact_process
    processing = PayLessonByBancontact.run(user: current_user, lesson: @lesson, transaction_id: params[:transactionId])
    if processing.valid?
      redirect_to lessons_path, notice: t('notice.booking_success')
    else
      redirect_to user_path(@lesson.teacher), notice: t('notice.booking_error')
    end
  end

  def topics
    @topics = @teacher.adverts.includes(:topic).where(topics: params.slice(:topic_group_id)).uniq
      .pluck_to_hash('topics.id as id', 'topics.title as title')
    render json: @topics
  end

  def levels
    @levels = @teacher.adverts.includes(advert_prices: :level).where(topic_id: params[:topic_id]).uniq
      .pluck_to_hash('levels.id as id', 'levels.fr as title')
    render json: @levels
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

  def set_lession
    @lesson = Lesson.drafts(current_user).first.try(:restore)
  end

  def lesson_params
    params.require(:lesson).permit(:student_id, :date, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end, :free_lesson).merge(:student_id => current_user.id)
  end

  def request_params
    params.require(:request).permit(:student_id, :level_id, :topic_id, :time_start, :hours, :minutes, :free_lesson).merge({
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
    render 'mango_account', :layout=>false and return false
  end


end
