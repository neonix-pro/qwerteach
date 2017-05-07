class RegistrationsController < Devise::RegistrationsController
  after_action :save_user_timezone, only: [:create]
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
    if resource.is_a?(Teacher)
      become_teacher_path(:general_infos)
    else
      if session[:user_redirect_to]
        session[:user_redirect_to]
      else
        onboarding_path(:choose_role)
      end
    end
  end

  def sign_up_params
    params.require(:user).permit(:firstname, :lastname, :email, :password)
  end

end