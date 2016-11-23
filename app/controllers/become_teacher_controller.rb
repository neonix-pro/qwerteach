class BecomeTeacherController < ApplicationController
  include Wicked::Wizard
  include MangopayAccount

  before_filter :authenticate_user!

  steps :general_infos, :avatar, :crop, :adverts, :banking_informations, :finish_postulation
  def show
    @user = current_user
    case step
      when :pictures
        @gallery = Gallery.find_by user_id: @user.id
      when :avatar
        if @user.avatar_file_name?
          jump_to(:adverts)
        end
      when :adverts
        @advert = Advert.new
        @adverts = Advert.where(:user => current_user)
      when :banking_informations
        @account = Mango::SaveAccount.new(user: current_user, first_name: current_user.firstname, last_name: current_user.lastname)
        @teacher = current_user
        @path = wizard_path
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
      when :general_infos
        @user.update_attributes(user_params)
      when :avatar
        @user.update_attributes(user_params)
      when :crop
        @user.update_attributes(user_params)
      when :adverts

      when :banking_informations
        saving = Mango::SaveAccount.run( mango_account_params.merge(user: current_user) )
        unless saving.valid?
          @account = saving
          jump_to(:adverts)
        end
    end
    render_wizard @user
  end

  private
  def user_params
    params.require(:user).permit(:mango_id, :crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname, :email, :birthdate, :description, :gender, :phonenumber, :avatar)
  end

  def gallery_params
    params.permit(:pictures, :user_id).merge(user_id: current_user.id)
  end
end