class RegistrationsController < Devise::RegistrationsController
  after_action :save_user_timezone, only: [:create]
  before_filter :configure_permitted_parameters, only: [:update]
  after_action :send_google_analytics, only: :create
  respond_to :html, :js

  def sign_up(resource_name, resource)
    sign_in(:user, resource)
  end

  private

  def save_user_timezone
    return unless resource.persisted?
    resource.update(time_zone: cookies[:time_zone])
  end
  
  def after_sign_up_path_for(resource)
    unless request.env['omniauth.origin']
      if resource.is_a?(Teacher)
        become_teacher_path(:general_infos)
      else
        if session[:user_redirect_to]
          session[:user_redirect_to]
        else
          onboarding_path(:choose_role)
        end
      end
    else
      request.env['omniauth.origin']
    end
  end

  def sign_up_params
    params.require(:user).permit(:firstname, :lastname, :email, :password)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update).push(:first_lesson_free)
  end

  def send_google_analytics
    begin
      tracker do |t|
        t.google_analytics :send, { type: 'event', category: 'Users', action: 'registration', label: 'new' }
      end
    rescue
    end
  end

end
