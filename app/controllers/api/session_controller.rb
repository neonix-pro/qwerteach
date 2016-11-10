class Api::SessionController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def login
    email = params[:user]['email']
    password = params[:user]['password']
    
    user = User.find_by_email(email.downcase)

    if user.nil?
      warden.custom_failure!
      render :json => {:success => "false", :info => "Loggin failed"}
    else
      if not user.valid_password?(password)
        render :json => {:success => "false", :info => "Loggin failed"}
      else
        render :json => {:success => "true", :info => "Logged in", :id => user.id}
      end 
    end
  end
  
end
