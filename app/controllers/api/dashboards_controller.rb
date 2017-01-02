class Api::DashboardsController < DashboardsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    render :json => {:upcoming_lessons => @upcoming_lessons}
  end
  
end
