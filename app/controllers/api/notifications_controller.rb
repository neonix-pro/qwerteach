class Api::NotificationsController < NotificationsController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
  end
  
  def get_notification_infos
    user = User.find(params[:sender_id])
    render :json => {:avatar => user.avatar.url(:small)}
  end
  
end
