class BecomeTeacherController < ApplicationController
	include Wicked::Wizard

	steps :general_infos, :avatar, :crop, :pictures, :adverts, :banking_informations

	def show
    @user = current_user
    case step
    when :pictures
      @gallery = Gallery.find_by user_id: @user.id
    when :avatar
      if @user.avatar_file_name?
        jump_to(:pictures) 
      end
    when :adverts
      @advert = Advert.new
      @adverts = Advert.where(:user=>current_user)
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
    when :general_infos
      @user.update_attributes(student_params)
    when :avatar
      @user.update_attributes(user_params)
    when :crop
      @user.update_attributes(user_params)
    when :pictures
      @gallery = Gallery.find_by user_id: @user.id
      @gallery.update_attributes(gallery_params)
      if params[:images]
        # The magic is here ;)
        params[:images].each { |image|
          @gallery.pictures.create(image: image) 
          nb = @gallery.pictures.count
        }
      end
    when :adverts
    when :banking_informations
    end
    render_wizard @user
  end

  private
  def student_params
    params.require(:student).permit(:crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname, :email, :birthdate, :description, :gender, :phonenumber, :avatar)
  end
  def user_params
    params.require(:user).permit(:crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname, :email, :birthdate, :description, :gender, :phonenumber, :avatar)
  end
  def gallery_params
    params.permit(:pictures, :user_id).merge(user_id: current_user.id)
  end

end
