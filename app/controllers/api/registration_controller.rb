class Api::RegistrationController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def create
    email = params[:user]['email']
    useremail = User.find_by_email(email.downcase)
    
    unless useremail.nil?
      render :json => {:success => "exist"}
      return
    end
    
    user = User.new(user_params)
    user.skip_confirmation!
    
    if user.save
      render :status => 200, :json => {:success => "true", :info => "Registered", :user => user.as_json, :id => user.id}
      return
    else
      warden.custom_failure!
      render :json => user.errors, :status => 422
    end
    
    redirect_to "/registration"
  end
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
  
end
