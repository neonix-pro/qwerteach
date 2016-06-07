class BecomeTeacherController < ApplicationController
  include Wicked::Wizard
  before_filter :authenticate_user!

  steps :general_infos, :avatar, :crop, :pictures, :adverts, :banking_informations, :finish_postulation
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
        @adverts = Advert.where(:user => current_user)
      when :banking_informations
        list = ISO3166::Country.all
        @list = []
        list.each do |c|
          t = [c.translations['fr'], c.alpha2]
          @list.push(t)
        end
        @user.load_mango_infos
        @user.load_bank_accounts
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
        @user.upgrade
      when :banking_informations
        mangoInfos = @user.mango_infos(params)
        begin
          if (!@user.mango_id)
            m = @user.create_mango_user(params)
          else
            m = MangoPay::NaturalUser.update(@user.mango_id, mangoInfos)
          end
          if params[:bank_account]
            case params[:bank_account]['Type']
              when 'iban'
                params[:bank_account] = params[:iban_account]
              when 'gb'
                params[:bank_account] = params[:gb_account]
              when 'us'
                params[:bank_account] = params[:us_account]
              when 'ca'
                params[:bank_account] = params[:ca_account]
              when 'other'
                params[:bank_account] = params[:other_account]
            end
            params[:bank_account][:OwnerName]=@user.firstname + ' '+@user.lastname
            params[:bank_account][:OwnerAddress] = m["Address"]

            MangoPay::BankAccount.create(@user.mango_id, params[:bank_account])
          end

        rescue MangoPay::ResponseError => ex
          #flash[:danger] = ex.details["Message"]
          errors = []
          ex.details['errors'].each do |name, val|
            errors.push("#{name}: #{val}")
          end
          flash[:danger] = errors.join("<br />").html_safe
          # jump_to(:banking_informations)
          redirect_to wizard_path(:banking_informations) and return
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