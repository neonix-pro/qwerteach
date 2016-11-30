class Api::WalletsController < WalletsController
  
  skip_before_filter :verify_authenticity_token
  
  def index_mangopay_wallet
    super
  end
  
  def update_mangopay_wallet
    super
  end
  
end
