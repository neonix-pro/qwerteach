class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  
  def create_postpayment
    defaults = {:payment_type=>1, :status=>0}
    params = defaults.merge(params)
    @payment = Payment.new(payment_params)
    if @payment.save
      flash[:success] = "la facture a bien été créée"     
    else
      flash[:danger] = 'Il y a eu un problème!'
    end
    redirect_to lessons_path
  end

  def make_transfert
    @user = current_user
    if !@user.mango_id
      list = ISO3166::Country.all
      @list = []
      list.each do |c|
        t = [c.translations['fr'], c.alpha2]
        @list.push(t)
      end
      @user.load_mango_infos
      @user.load_bank_accounts
      render 'wallets/_mangopay_form' and return
    end
  end
  
  def send_make_transfert  
    unless transaction_infos
      return redirect_to url_for(controller: 'wallets', action: 'index_mangopay_wallet')
    end
    begin
      if(@user.is_solvable?(@amount))
        bonus_transfer
        normal_transfer
        flash[:success]='Le transfer de '+@amount/100+' EUR a bien été effectué.'     
      else
        flash[:danger]='Votre solde est insuffisant. Rechargez en premier lieu votre portefeuille.'
        return
      end
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
    end
  end

  def transaction_infos
    @user = current_user
    @amount = params[:amount].to_f * 100
    @fees = 0 * @amount
    @beneficiary = User.find(params[:other_part])
    
    unless valid_users_infos
      return false
    end

    begin
      @wallets ||= @user.wallets
      @beneficiary_wallet = @beneficiary.wallets.first
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      return false
    end
  end

  def bonus_transfer
    if(amount_bonus_transfer > 0)
      bonus_transfer = MangoPay::Transfer.create({
                                           :AuthorId => current_user.mango_id,
                                           :DebitedFunds => {
                                               :Currency => "EUR",
                                               :Amount => @amount_bonus_transfer
                                           },
                                           :Fees => {
                                               :Currency => "EUR",
                                               :Amount => @fees
                                           },
                                           :DebitedWalletID => @wallets.second["Id"],
                                           :CreditedWalletID => @beneficiary_wallet["Id"]
                                       })
      valid_transfer(bonus_transfer)
    end
  end
  
  def normal_transfer
    if(@amount_normal > 0)
      normal_transfer = MangoPay::Transfer.create({
                                              :AuthorId => current_user.mango_id,
                                              :DebitedFunds => {
                                                  :Currency => "EUR",
                                                  :Amount => @amount_normal_transfer
                                              },
                                              :Fees => {
                                                  :Currency => "EUR",
                                                  :Amount => @fees
                                              },
                                              :DebitedWalletID => @wallets.first["Id"],
                                              :CreditedWalletID => @beneficiary_wallet["Id"]
                                          })

      valid_transfer(normal_transfer)
    end
  end

  private
    def valid_transfer(transfer)
      if(transfer['ResultCode']!='000000')
        flash[:danger]='Il y a eu un problème lors du transfer. Veuillez ré-essayer.'
        redirect_to url_for(controller: 'wallets', action: 'index_mangopay_wallet')
      end
    end

    def amount_bonus_transfer
      @amount_bonus_transfer = [@amount, @wallets.second['Balance']['Amount'] ].min
    end

    def amount_normal_transfer
      @amount_normal = @amount - @amount_bonus_transfer
    end

    def valid_users_infos
      unless(@user.mango_id)
        flash[:danger]="Vous devez d'abord créer un portefeuille virtuel."
        return false
      end
      unless(@beneficiary.mango_id)
        flash[:danger]="le bénéficiaire n'a pas de portefeuille virtuel sur Qwerteach. Il doit en créer un avant de pouvoir recevoir des fonds!"
        return false
      end
    end
    # assure qu'un payment est toujours associé à une lesson
    def payment_params
      params.require(:lesson)
    end

end