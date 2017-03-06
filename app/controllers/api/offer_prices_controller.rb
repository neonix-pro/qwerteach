class Api::OfferPricesController < OfferPricesController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    super
  end
  
end
