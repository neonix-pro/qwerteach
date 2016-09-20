class ApplicationController < ActionController::Base
  # redirects if catches cancan access denied
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  rescue_from Mango::UserDoesNotHaveAccount do |exception|
    redirect_to edit_wallet_path(redirect_to: request.fullpath), alert: t('notice.missing_account')
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # To protect against all other forged requests, we introduce a required
  # security token that our site knows but other sites don't know. We include
  # the security token in requests and verify it on the server.
  protect_from_forgery with: :exception
  # loads devise permitted params
  before_filter :configure_permitted_parameters, if: :devise_controller?
  after_filter :flash_to_headers

  def bigbluebutton_role(room)
      :moderator
  end

  def bigbluebutton_can_create?(room, role)
    true
  end

  def current_timestamp
    Time.now.to_i
  end

  helper_method :twelve_teacher, :countries_list

  def flash_to_headers
    return unless request.xhr?
    return if flash_message.nil?
    response.headers['X-Message'] = flash_message
    response.headers["X-Message-Type"] = flash_type.to_s

    flash.discard  # discard flash messages after encoding so don't appear twice
  end

  # Use require to define permitted params
  protected
    before_filter do
      resource = controller_name.singularize.to_sym
      method = "#{resource}_params"
      params[resource] &&= send(method) if respond_to?(method, true)
    end
    # Permitted params pour Devise sign up & update
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) do |u|
        u.permit(:email, :password, :password_confirmation, :current_password, :time_zone)
      end
      devise_parameter_sanitizer.for(:account_update) {
          |u| u.permit(
            :crop_x, :crop_y, :crop_w, :crop_h,:level, :pictures, :gallery, :avatar, :occupation, :level_id, :type, :birthdate, :description, :gender, :phonenumber, :firstname, :lastname, :email, :password, :password_confirmation, :current_password, :accepts_post_payments, :time_zone
        ) }
    end

  private

  def check_mangopay_account
    raise Mango::UserDoesNotHaveAccount if current_user.mango_id.blank?
  end

  def countries_list
    @list ||= ISO3166::Country.all.map{|c| [c.translations['fr'], c.alpha2] }
  end

  def flash_message
    [:error, :warning, :notice].each do |type|
      return flash[type] unless flash[type].blank?
    end
    nil
  end

  def flash_type
    [:error, :warning, :notice].each do |type|
      return type unless flash[type].blank?
    end
    nil
  end

end