class Api::WalletsController < WalletsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index_mangopay_wallet
    super
    
    #author_names = Array.new
    #credited_user_names = Array.new
    #transactions = Kaminari.paginate_array(@transactions).page(params[:page]).per(5)
    
    #transactions.each do |t|
      #author_name = User.find_by(mango_id: t.author_id).name
      #credited_user_name = User.find_by(mango_id: t.credited_user_id).name
      #author_names.push(author_name)
      #credited_user_names.push(credited_user_name)
    #end
    
    #respond_to do |format|
      #format.html {}
      #format.js {}
      #format.json {render :json => {:success => "loaded", :account => @account, :bank_accounts => @bank_accounts, 
      #:user_cards => @cards, :transactions => transactions, :author_names => author_names, :credited_user_names => credited_user_names}}
    #end
    
  end
  
  def update_mangopay_wallet
    super
  end
  
  def direct_debit_mangopay_wallet
    super
  end
  
  def load_wallet
    super
  end
  
  def card_info
    super
  end
  
  def update_bank_accounts
    super
  end
  
  def desactivate_bank_account
    super 
  end
  
  def make_payout
    super
  end
  
  def payout
    super
  end
  
  def get_total_wallet
    user = User.find_by_id(params["user_id"])
    render :json => {:total_wallet => user.total_wallets_in_cents}
  end
  
end
