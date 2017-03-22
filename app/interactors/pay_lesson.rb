class PayLesson < ActiveInteraction::Base
  object :controller, class: ApplicationController
  object :lesson, class: Lesson
  string :credit_card_complete_url, default: nil
  string :bancontact_complete_url, default: nil

  delegate :render, :redirect_to, :respond_to, :params, :lessons_path, to: :controller
  delegate :bancontact_process_user_lesson_requests_url, :credit_card_process_user_lesson_requests_url, to: :controller

  def execute
    case mode
      when 'transfert'  then transfert
      when 'bancontact' then bancontact
      when 'cd' then credit_card
    end
  end

  private

  def transfert
    paying = PayLessonByTransfert.run(user: user, lesson: lesson, wallet: beneficiary_wallet)
    if paying.valid?
      respond_to do |format|
        format.html {redirect_to lessons_path}
      end
    else
      controller.instnce_variable_set :@card_registration, Mango::CreateCardRegistration.run(user: user).result
      render 'errors', :layout=>false, locals: {object: paying}
    end
  end

  def bancontact
    return_url = bancontact_url
    payin = Mango::PayinBancontact.run(user: user, amount: lesson.price,
                                       return_url: return_url, wallet: beneficiary_wallet)
    if payin.valid?
      redirect_to payin.result.redirect_url and return
      #render js: "window.location = '#{payin.result.redirect_url}'" and return
    else
      render 'errors', :layout=>false, locals: {object: payin}
    end
  end

  def credit_card
    return_url = credit_card_url
    payin = Mango::PayinCreditCard.run({user: user, amount: lesson.price,
                                        card_id: params[:card_id], return_url: return_url, wallet: beneficiary_wallet})

    if payin.valid?
      result = payin.result
      if result.secure_mode_redirect_url.present?
        redirect_to result.secure_mode_redirect_url
        #render js: "window.location = '#{result.secure_mode_redirect_url}'" and return
      else
        paying = PayLessonWithCard.run(user: user, lesson: lesson, transaction_id: result.id)
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

  def beneficiary_wallet
    lesson.past? ? teacher.normal_wallet.try(:id) : 'transaction'
  end

  def teacher
    lesson.teacher
  end

  def user
    controller.current_user
  end

  def mode
    params[:mode]
  end

  def credit_card_url
    credit_card_complete_url || credit_card_process_user_lesson_requests_url(teacher)
  end

  def bancontact_url
    bancontact_complete_url || bancontact_process_user_lesson_requests_url(teacher)
  end


end