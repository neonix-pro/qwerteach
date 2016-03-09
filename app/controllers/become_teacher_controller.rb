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
    when :banking_informations
      list = ISO3166::Country.all
      @list = []
      list.each do |c|
        t = [c.translations['fr'], c.alpha2]
        @list.push(t)
      end
      if(@user.mango_id)
        m = MangoPay::NaturalUser.fetch(@user.mango_id)
        @user.address = m['Address']
        @user.countryOfResidence = m['CountryOfResidence']
        @user.nationality = m['Nationality']
        @b = MangoPay::BankAccount.fetch(@user.mango_id)
        if(@b.empty?)
          @b = {}
        else
          @b = @b.first
        end
      else
        @user.address = {}
      end
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
      @user.upgrade
      mangoInfos = @user.mango_infos(params)
      begin
        if(!@user.mango_id)
          m = MangoPay::NaturalUser.create(mangoInfos)
          @user.mango_id = m['Id']
          @user.save
        else
          m = MangoPay::NaturalUser.update(@user.mango_id, mangoInfos)
        end

        params[:bank_account][:Type]='IBAN'
        params[:bank_account][:OwnerName]=@user.firstname + ' '+@user.lastname
        params[:bank_account][:OwnerAddress] = m["Address"]

        MangoPay::BankAccount.create(@user.mango_id, params[:bank_account])

        rescue MangoPay::ResponseError => ex
          flash[:danger] = ex.details["Message"]
          ex.details['errors'].each do |name, val|
            flash[:danger] += " #{name}: #{val} \n\n"
          end
          jump_to(:banking_informations)
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