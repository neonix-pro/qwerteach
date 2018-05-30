class RegistrationsController < Devise::RegistrationsController
  after_action :save_user_timezone, only: [:create]
  before_filter :configure_permitted_parameters, only: [:update]
  after_action :send_google_analytics, only: :create
  after_action :update_drip_subscription, only: [:update]
  after_action :send_event_user_status, only: [:update]
  respond_to :html, :js

  def sign_up(resource_name, resource)
    sign_in(:user, resource)
  end

  def destroy
    @user = current_user
    # unsubscribe from drip, sendgrid... Send email?
    drip
    @drip.delete_subscriber(@user.email)
    @user.update(blocked: true)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  private

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
    params.require(:user).permit(:firstname, :lastname, :email, :password, :source, :type)
  end

  def configure_permitted_parameters
    # Perhaps you need to add :firstname and :lastname ?
    devise_parameter_sanitizer.for(:account_update).push(:first_lesson_free)
  end

  def send_google_analytics
    if current_user
      category = "Inscription - #{session[:supposed_user_type].nil? ? '?': session[:supposed_user_type]}"
      action = "Inscription #{current_user.provider.nil? ? 'e-mail' : current_user.provider}"
      begin
        tracker do |t|
          t.google_analytics :send, { type: 'event', category: category, action: action, label: "user id: #{current_user.id}" }
        end
      rescue
      end
    end
  end

  def update_drip_subscription
    unless current_user.is_a?(Teacher) || current_user.description == ''
      drip
      @drip.unsubscribe(current_user.email, '536758291')
      @drip.subscribe(current_user.email, '120243932', double_optin: false)
    end
  end

  def send_event_user_status
    unless current_user.is_a?(Teacher) || current_user.description == ''
      begin
        tracker do |t|
          t.google_analytics :send, { type: 'event', category: 'Inscription - prof', action: 'Confirmer sa postulation', label: "user id: #{current_user.id}" }
        end
      rescue
      end
    end
  end

end
