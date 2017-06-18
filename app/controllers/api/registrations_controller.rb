class Api::RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def create
    @user = User.where(email: sign_up_params[:email]).first
    if @user.present?
      render :json => {:success => "exist"} and return
    end
    
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render :json => {:success => "true", :user => resource} and return
      else
        expire_data_after_sign_in!
        render :json => {:success => "false", :error => resource.errors} and return
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
    end
  end
  
end
