class Api::SessionsController < Devise::SessionsController
  
  skip_before_filter :verify_authenticity_token
  skip_before_action :verify_signed_out_user
  respond_to :json
  
  def create
    self.resource = warden.authenticate(auth_options)
    if self.resource
      sign_in(resource_name, resource)
      render :json => {:success => "true", :user => current_user}
      return
    end
    
    render :json => {:success => "false"}
  end
  
  def destroy
    super do
      render :json => {:success => "true"}
      return
    end
  end

end