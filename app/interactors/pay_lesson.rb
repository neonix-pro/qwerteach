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
      controller.tracker do |t|
        t.google_analytics :send, { type: 'event', category: 'Réservation - élève', action: 'Payer reservation par Portefeuille virtuel', label: "Prof id: #{lesson.teacher.id}", value: "#{lesson.price.to_s}" }
      end
      send_notification
      respond_to do |format|
        format.js {render 'finish', :layout => false}
        format.json {render :json => {:message => "finish"}}
        format.html {render 'finish' }
      end
    else
      controller.instance_variable_set :@card_registration, Mango::CreateCardRegistration.run(user: user).result
      respond_to do |format|
        format.js {render 'errors', :layout=>false, locals: {object: paying}}
        format.json {render :json => {:message => "errors"}}
        format.html {render 'finish', locals: {object: paying} }
      end
    end
  end

  def bancontact
    return_url = bancontact_url
    payin = Mango::PayinBancontact.run(user: user, amount: lesson.price,
                                       return_url: return_url, wallet: beneficiary_wallet)
    if payin.valid?
      respond_to do |format|
        format.js { redirect_to payin.result.redirect_url }
        format.json {render :json => {:message => "result", :url => payin.result.redirect_url}}
      end
    else
      respond_to do |format|
        format.js {render 'errors', :layout=>false, locals: {object: payin}}
        format.json {render :json => {:message => "errors"}}
      end
    end
  end

  def credit_card
    return_url = credit_card_url
    payin = Mango::PayinCreditCard.run({user: user, amount: lesson.price,
                                        card_id: params[:card_id], return_url: return_url, wallet: beneficiary_wallet})

    if payin.valid?
      result = payin.result
      if result.secure_mode_redirect_url.present?
        #redirect_to result.secure_mode_redirect_url
        #render js: "window.location = '#{result.secure_mode_redirect_url}'" and return
        respond_to do |format|
          format.js { redirect_to result.secure_mode_redirect_url }
          format.json { render :json => {:message => "result", :url => result.secure_mode_redirect_url} }
        end
      else
        #action = lesson.status == 'pending_student' ? 'accepted_by_student' : 'created_by_student'
        paying = PayLessonWithCard.run(user: user, lesson: lesson, transaction_id: result.id)
        if !paying.valid?
          respond_to do |format|
            format.js {render 'errors', :layout=>false, locals: {object: paying}}
            format.json {render :json => {:message => "errors"}}
          end
        else
          send_notification
          #controller.ga_track_event("Booking", action, "Prof id: #{lesson.teacher.id}")
          #controller.ga_track_event("Payment", "Created",  "Credit Card", lesson.price)
          respond_to do |format|
            format.js {render 'finish', :layout => false}
            format.json {render :json => {:message => "finish"}}
          end
        end
      end
    else
      respond_to do |format|
        format.js { render 'errors', :layout=>false, locals: {object: payin} }
        format.json {render :json => {:message => "errors"}}
      end
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
        
  def send_notification
    Pusher.notify(["#{@lesson.teacher.id}"], {fcm: {notification: {body: "#{@lesson.student.name} vous adresse une demande de cours.",
      icon: 'androidlogo', click_action: "MY_LESSONS"}}})
  end

end