class Api::MessagesController < MessagesController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    super
  end
  
end
