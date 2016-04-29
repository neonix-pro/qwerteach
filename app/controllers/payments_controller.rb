class PaymentsController < ApplicationController
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
      render 'paiements/_mangopay_form' and return
    end
  end
  

  def transaction_infos
    @amount = params[:amount].to_f * 100
    @fees = 0 * @amount
    @wallets ||= MangoPay::User.wallets(current_user.mango_id)
    @beneficiary ||= User.find(params[:other_part])
    @beneficiary_wallet ||= MangoPay::User.wallets(@beneficiary.mango_id).first
  end
  
  def total_wallets
    @wallets.first['Balance']['Amount'] + @wallets.second['Balance']['Amount']
  end
  
  def is_solvable
    @amount < total_wallets
  end
  
  def send_make_transfert
    begin
      transaction_infos
      if(is_solvable)
        bonus_transfer
        normal_transfer
        flash[:success]='Le transfer de '+@amount/100+' EUR a bien été effectué.'     
      else
        flash[:danger]='Votre solde est insuffisant. Rechargez en premier lieu votre portefeuille.'
        return
      end
    rescue MangoPay::ResponseError => ex
      flash[:danger] = ex.details["Message"]
      #redirect_to url_for(controller: 'wallets', action: 'index_mangopay_wallet')
    end
  end

  def amount_bonus_transfer
    @amount_bonus_transfer ||= [@amount, @wallets.second['Balance']['Amount'] ].min
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

  def amount_normal_transfer
    @amount_normal = @amount - @amount_bonus_transfer
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

  def valid_transfer(transfer)
    if(transfer['ResultCode']!='000000')
      flash[:danger]='Il y a eu un problème lors du transfer. Veuillez ré-essayer.'
      redirect_to url_for(controller: 'wallets', action: 'index_mangopay_wallet')
    end
  end
end