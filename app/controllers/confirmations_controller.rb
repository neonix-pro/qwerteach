class ConfirmationsController < Devise::ConfirmationsController

  private

  def after_confirmation_path_for(resource_name, resource)
    if session[:user_redirect_to]
      session[:user_redirect_to]
    else
      root_path
    end
  end

end