class Api::WalletsController < WalletsController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index_mangopay_wallet
    super
  end

  def transactions_index
    super
  end

  def edit_mangopay_wallet
    super
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
