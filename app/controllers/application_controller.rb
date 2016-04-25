class ApplicationController < ActionController::Base
  # Rediriger en cas d'exception CanCan car pas le droit d'accès
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # Protéger le site en vérifiant les sources des requetes extérieures
  # To protect against all other forged requests, we introduce a required
  # security token that our site knows but other sites don't know. We include
  # the security token in requests and verify it on the server.
  protect_from_forgery with: :exception
  # loader les permitted params pour devise
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # Pour définir les permitted params dans les controllers en utilisant require
  protected
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  # Permitted params pour Devise pour l'inscription et la maj d'un compte existant
  def configure_permitted_parameters

    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation, :current_password)
    end
    devise_parameter_sanitizer.for(:account_update) {
        |u| u.permit(
          :crop_x, :crop_y, :crop_w, :crop_h,:level, :pictures, :gallery, :avatar, :occupation, :level_id, :type, :birthdate, :description, :gender, :phonenumber, :firstname, :lastname, :email, :password, :password_confirmation, :current_password, :accepts_post_payments
      ) }

  end

  def bigbluebutton_role(room)
    if room.private or bigbluebutton_user.nil?
      :key # ask for a key
    else
      :moderator
    end
  end

  def bigbluebutton_can_create?(room, role)
    unless bigbluebutton_user.nil?           # there's a logged user
      if room.owner_type == "User"           # the room belongs to a user
        if room.owner.id == current_user.id  # the current_user owns this room
          true                               # allow him to create a meeting!
        else                                 # the current user is not the owner
          false                              # can't create
        end
      end
    else                                     # no user logged = anonymous access
      false                                  # can't create
    end
  end

#  rescue_from ActiveRecord::RecordNotFound do
#    flash[:warning] = 'Resource not found.'
#    redirect_back_or root_path
#  end

#  def redirect_back_or(path)
#    redirect_to request.referer || path
#  end
end