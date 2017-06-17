class BecomeTeacherController < ApplicationController
  include Wicked::Wizard
  include MangopayAccount

  before_filter :authenticate_user!

  steps :general_infos, :avatar, :offers, :banking_informations, :finish_postulation

  DESCRIPTION_QUESTIONS = ["Présentez-vous en quelques lignes",
                           "Quel a été votre parcours ?",
                           "Quel est le domaine dans lequel vous souhaitez enseigner et à quel public ?",
                           "Qu’est-ce qui vous fascine par rapport à votre domaine d’étude ?",
                           "Pourquoi êtes-vous un bon prof ? Quelle est la méthode de travail que vous utilisez ?",
                           "Avez-vous de l'expérience dans l'enseignement ? Si oui, comment l'avez-vous acquise ?"]

  def show
    @user = current_user
    case step
      when :general_infos
        @levels = Level.where(code: 'scolaire').group(:be).order(:id).map{|l| [l.be, l.id]}
        @description_questions = DESCRIPTION_QUESTIONS
      when :pictures
        @gallery = Gallery.find_by user_id: @user.id
      when :avatar
        if @user.avatar_file_name?
          #jump_to(:offers)
        end
      when :offers
        @offer = Offer.new
        @offers = Offer.where(:user => current_user)
      when :banking_informations
        @account = Mango::SaveAccount.new(user: current_user, first_name: current_user.firstname, last_name: current_user.lastname)
        @teacher = current_user
        @path = wizard_path
        @bank_account = Mango::CreateBankAccount.new(user: current_user)
        if @user.offers.empty?
          flash[:warning]="Vous n'avez pas enregistré vos annonces de cours. Tant que ceci ne sera pas fait, votre candidature ne sera pas prise en compte. <br />"
          flash[:warning]+= view_context.link_to 'Ajouter une annonce', become_teacher_path(:offers)
        end
    end
    render_wizard
  end

  def update
    @user = current_user
    case step
      when :general_infos
        merge_description
        @user.update_attributes(user_params)
      when :avatar
        @user.update_attributes(user_params)
      when :offers

      when :banking_informations
        saving = Mango::SaveAccount.run( mango_account_params.merge(user: current_user) )
        unless saving.valid?
          @account = saving
          jump_to(:offers)
        end
        creation = Mango::CreateBankAccount.run bank_account_params.merge(user: @user)
    end
    render_wizard @user
  rescue MangoPay::ResponseError => ex
    flash[:danger] = t('notice.general_error', message: ex.details["Message"].to_s)
  end

  private
  def user_params
    params.require(:user).permit(:mango_id, :crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname, 
      :email, :birthdate, :description, :gender, :avatar, :phonenumber, :level_id, :occupation, :phone_number, :phone_country_code)
  end

  def gallery_params
    params.permit(:pictures, :user_id).merge(user_id: current_user.id)
  end

  def merge_description
    params[:user][:description]=""
    DESCRIPTION_QUESTIONS.each_with_index do |question, index|
      params[:user][:description] += "<h3>#{question}\n</h3>" unless (index == 0 || params["description_#{index}"].empty?)
      params[:user][:description] += "#{params["description_#{index}"]}\r\n\r\n" unless params["description_#{index}"].empty?
    end
  end
  def bank_account_params
    if %w(iban gb us ca other).include?( (params[:bank_account][:type] rescue nil) )
      params.fetch("#{params[:bank_account][:type]}_account").permit!.merge( params[:bank_account] )
    else
      {}
    end
  end
end