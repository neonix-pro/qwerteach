# Controller pour Users (gérés par Devise)
require "uri"
require "net/http"
class RegistrationsController < Devise::RegistrationsController

  def update
    @user = User.find(current_user.id)
    params[:user].permit(:crop_x, :crop_y, :crop_w, :crop_h, :level, :avatar, :occupation, :level_id, :type, :firstname, :lastname, :birthdate, :description, :gender, :phonenumber, :email, :password, :password_confirmation, :current_password, :accepts_post_payments, :time_zone)
    # On vérifie que l'on a besoin d'un mdp pour updater ce/ces champs là
    successfully_updated = if needs_password?(@user, params)
                             @user.update_with_password(devise_parameter_sanitizer.sanitize(:account_update))
                           else
                             # remove the virtual current_password attribute
                             # update_without_password doesn't know how to ignore it
                             params[:user].delete(:current_password)
                             @user.update_without_password(devise_parameter_sanitizer.sanitize(:account_update))
                           end

    if successfully_updated
      # Il ne faut pas cropper l'avatar
      if params[:user][:avatar].blank?

        set_flash_message :notice, :updated
        # Sign in the user bypassing validation in case their password changed
        sign_in @user, :bypass => true
        redirect_to after_update_path_for(@user)
      else
        # Il faut cropper l'avatar
        render "crop"
      end
    else
      render "edit"
    end

  end

  def pwd_edit
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end

  private
  # on vérifier si l'email a changé ou le mdp pour savoir s'il faut les vérifier
  def needs_password?(user, params)
    (params[:user].has_key?(:email) && user.email != params[:user][:email]) || !params[:user][:password].blank?
  end

end