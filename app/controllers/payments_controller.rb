class PaymentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @lessons_given = current_user.lessons_given
    @lessons_received = current_user.lessons_received

    @factures_given = []
    @factures_received = []

    @lessons_given.each do |lg|
      lg.payments.each { |l| @factures_given.push(l) }
    end

    @lessons_received.each do |lg|
      lg.payments.each { |l| @factures_received.push(l) }
    end
  end

  def payerfacture
    @payment = Payment.find(params[:payment_id])
    if @payment.paid? || @payment.canceled? || @payment.blocked?
      flash[:danger] = "Paiement impossible"
    else
      @amount = @payment.price.to_f
      @other = @payment.lesson.teacher
      payment_service = MangopayService.new(:user => current_user)
      payment_service.set_session(session)
      case payment_service.send_make_transfert(
          {:amount => @amount, :beneficiary => @other})
        when 0
          @payment.update_attributes(:status => 1)
          flash[:notice] = "Le transfert s'est correctement effectué."
          redirect_to lessons_path and return
        when 1
          flash[:alert] = "Il y a eu une erreur lors de la transaction. Veuillez réessayer."
          redirect_to lessons_path and return
        when 2
          flash[:alert] = "Vous devez d'abord correctement compléter vos informations de paiement."
          list = ISO3166::Country.all
          @list = []
          list.each do |c|
            t = [c.translations['fr'], c.alpha2]
            @list.push(t)
          end
          render 'wallets/_mangopay_form' and return
        when 3
          flash[:alert] = "Votre bénéficiaire n'a pas encore complété ses informations de paiement. Il faudra réessayer plus tard."
          redirect_to root_path and return
        when 4
          flash[:alert] = "Votre solde est insuffisant. Il faut d'abord recharger votre compte."
          redirect_to direct_debit_path and return
        else
          flash[:alert] = "Erreur inconnue."
          redirect_to root_path and return
      end
    end
    redirect_to lessons_path
  end

  def bloquerpayment
    payments = Payment.where(:lesson_id => params[:lesson_id])

    payments.each do |payment|
      #On vérifie si le payment est déjà Blocked ou Canceled
      if payment.blocked?|| payment.canceled?
        flash[:danger] = "Paiement déjà bloquer"
      else
        payment.update_attributes(:status => 3)
        flash[:success] = "Votre paiement est désormais bloqué"
      end
    end

    redirect_to lessons_path
  end

  def debloquerpayment 
    payments = Payment.where(:lesson_id => params[:lesson_id])
    
    payments.each do |payment|
      #On vérifie que le payment est en Blocked soit en Litige 
      if payment.blocked?
        flash[:sucess] = "Votre litige est retiré"
        payment.update_attributes(:status => 0)
      else
        flash[:warning] = "Vous me pouvez pas faire un contre litige"
      end
    end
    redirect_to lessons_path
  end
  
  def create_postpayment
    if (postpayment_lesson.present?)
      flash[:danger] = 'Il y a déjà une facture pour ce cours.'
    else
      price = Lesson.find(params[:lesson_id]).price
      postpayment_params = {:lesson_id => params[:lesson_id], :payment_type => 1, :status => 0, :price => price}
      @payment = Payment.new(postpayment_params)
      if @payment.save
        flash[:success] = "la facture a bien été créée"
      else
        flash[:danger] = 'Il y a eu un problème!'
      end
    end
    redirect_to lessons_path
  end

  def edit_postpayment
    @payment = Payment.find(params[:payment_id])
  end

  def send_edit_postpayment
    @payment = Payment.find(params[:payment_id])
    respond_to do |format|
      if @payment.update_attributes(edit_params)
        format.html { redirect_to payments_index_path, notice: 'La facture a été correctement modifiée.' }
      else
        format.html { redirect_to payments_index_path, notice: 'Il y a eu un problème. Veuillez réessayer.' }
      end
    end
  end

  def show

  end

  private
 
  def postpayment_lesson
    payment = Payment.find_by(:lesson_id => params[:lesson_id], :payment_type => 1)
  end

  def prepayment_lesson
    payment = Payment.find_by(:lesson_id => params[:lesson_id], :payment_type => 0)
  end

  def edit_params
    params.require(:payment).permit(:price)
  end

end