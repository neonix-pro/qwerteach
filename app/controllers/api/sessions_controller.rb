class Api::SessionsController < Devise::SessionsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def new
    super
  end
  
  def create
    super do
      render :json => {:success => "true", :info => "Logged in", :data => {:user => current_user.as_json}}
      return
    end
  end
  
  def destroy
    super do
      render :json => {:success => "true", :info => "Logged out", :data => {}}
      return
    end
  end
  
  def failure
    render :json => {:success => "false", :info => "Login Failed", :data => {}}
    return
  end
  
end
