class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?
  protected
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  def configure_permitted_parameters

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, :current_password)
    end
    devise_parameter_sanitizer.for(:account_update) {
        |u| u.permit(
         :level, :pictures, :gallery, :avatar, :occupation, :level_id, :type, :birthdate, :description, :gender, :phonenumber, :firstname, :lastname, :email, :password, :password_confirmation, :current_password
      ) }

  end

end