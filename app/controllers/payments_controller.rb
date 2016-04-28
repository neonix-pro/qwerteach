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
      render 'wallets/_mangopay_form' and return
    end
  end

  def send_make_transfert
    amount = params[:amount].to_f * 100
    fees = 0 * amount
    @wallet = MangoPay::User.wallets(current_user.mango_id).first
    walletcredit = @wallet['Balance']['Amount']
    @bonus_wallet = MangoPay::User.wallets(current_user.mango_id).second
    bonuscredit = @bonus_wallet['Balance']['Amount']
    @other = User.find(params[:other_part])
    @other_wallet = MangoPay::User.wallets(@other.mango_id).first

    if amount > (walletcredit + bonuscredit)
      flash[:danger]='Votre solde est insuffisant. Rechargez en premier lieu votre portefeuille.'
       # redirect_to url_for(controller: 'wallets',
        #    action: 'index_mangopay_wallet') and return
      return
    end

    if bonuscredit == 0
      repl = MangoPay::Transfer.create({
                                           :AuthorId => current_user.mango_id,
                                           :DebitedFunds => {
                                               :Currency => "EUR",
                                               :Amount => amount
                                           },
                                           :Fees => {
                                               :Currency => "EUR",
                                               :Amount => fees
                                           },
                                           :DebitedWalletID => @wallet["Id"],
                                           :CreditedWalletID => @other_wallet["Id"]
                                       })
      if repl["ResultCode"]=="000000"
        flash[:notice] ='Le transfert a correctement été effectué.'
        session[:lesson][:transaction_id] = repl['Id']
      else
        flash[:danger]='Veuillez réessayer'
      end
      # redirect_to url_for(controller: 'wallets',
       # action: 'index_mangopay_wallet') and return
      return
    else
      rest = amount - bonuscredit
      if rest > 0
        amount = bonuscredit
      end
      repl = MangoPay::Transfer.create({
                                           :AuthorId => current_user.mango_id,
                                           :DebitedFunds => {
                                               :Currency => "EUR",
                                               :Amount => amount
                                           },
                                           :Fees => {
                                               :Currency => "EUR",
                                               :Amount => fees
                                           },
                                           :DebitedWalletID => @bonus_wallet["Id"],
                                           :CreditedWalletID => @other_wallet["Id"]
                                       })
      if repl["ResultCode"]=="000000"
        flash[:notice] ='Le transfert a correctement été effectué. Montant déduit : '+ amount.to_s
        session[:lesson][:transaction_id] = repl['Id']
      else
        flash[:danger]='Veuillez réessayer, il y a eu un problème.Montant déduit = ' + amount.to_s
       #       redirect_to url_for(controller: 'wallets',
        # action: 'index_mangopay_wallet') and return
        return
      end
      if rest > 0
        repl2 = MangoPay::Transfer.create({
                                              :AuthorId => current_user.mango_id,
                                              :DebitedFunds => {
                                                  :Currency => "EUR",
                                                  :Amount => rest
                                              },
                                              :Fees => {
                                                  :Currency => "EUR",
                                                  :Amount => fees
                                              },
                                              :DebitedWalletID => @wallet["Id"],
                                              :CreditedWalletID => @other_wallet["Id"]
                                          })
        if repl2["ResultCode"]=="000000"
          flash[:notice] ='Le transfert a correctement été effectué. Montant diff = ' + rest.to_s
          session[:lesson][:transaction_id] = repl['Id']
        else
          flash[:danger]='Veuillez réessayer, il y a eu un problème. Montant diff = ' + rest.to_s
        end
      end
     # redirect_to url_for(controller: 'wallets',
      #                    action: 'index_mangopay_wallet')
    end
  rescue MangoPay::ResponseError => ex
    flash[:danger] = ex.details["Message"] + amount.to_s
    #ex.details['errors'].each do |name, val|
    # flash[:danger] += " #{name}: #{val} \n\n"
    #end
    #flash[:danger] = repl2["RedirectURL"]
  end

end
