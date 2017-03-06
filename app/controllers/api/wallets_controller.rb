class Api::WalletsController < WalletsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index_mangopay_wallet
    super
    transactions = Kaminari.paginate_array(@transactions).page(params[:page]).per(5)
    render :json => {:success => "loaded", :account => @account, :bank_accounts => @bank_accounts, 
      :user_cards => @cards, :transactions => transactions}
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
  
  def find_users_by_mango_id
    author_name = User.find_by(mango_id: params["author_id"]).name
    credited_user_name = User.find_by(mango_id: params["credited_user_id"]).name
    render :json => {:author => author_name, :credited_user => credited_user_name}
  end
  
end
