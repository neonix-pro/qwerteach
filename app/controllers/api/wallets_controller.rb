class Api::WalletsController < WalletsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index_mangopay_wallet
    super
    render :json => {:success => "loaded", :account => @account.as_json, :transactions => @transactions.as_json, :cards => @cards.as_json}
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
  
  def get_total_wallet
    user = User.find_by_id(params[:user]["id"])
    total_wallet = user.total_wallets_in_cents
    render :json => {:total_wallet => total_wallet.as_json}
  end
  
  def check_user_wallet
    if current_user.mango_id.present?
      respond_to do |format|
        format.html {}
        format.json {render :json => {:message => "true"}}
      end and return
    else
      respond_to do |format|
        format.html {}
        format.json {render :json => {:message => "false"}}
      end and return
    end
  end
  
  def find_users_by_mango_id
    author_name = User.find_by(mango_id: params["author_id"]).name
    credited_user_name = User.find_by(mango_id: params["credited_user_id"]).name
    transaction_id = params["transaction_id"]
    render :json => {:author => author_name, :credited_user => credited_user_name, :transaction => transaction_id}
  end
  
end
