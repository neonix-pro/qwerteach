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
          jump_to(:offers)
        end
      when :offers
        @offer = Offer.new
        @offers = Offer.where(:user => current_user)
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
        merge_phonenumber
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
    end
    render_wizard @user
  end

  private
  def user_params
    params.require(:user).permit(:mango_id, :crop_x, :crop_y, :crop_w, :crop_h, :firstname, :lastname, :email, :birthdate, :description, :gender, :avatar, :phonenumber, :level_id, :occupation)
  end

  def gallery_params
    params.permit(:pictures, :user_id).merge(user_id: current_user.id)
  end

  def merge_phonenumber
    params[:user][:phonenumber] = "#{params[:phonenumber_prefix]}#{params[:user][:phonenumber]}"
  end

  def merge_description
    params[:user][:description]=""
    DESCRIPTION_QUESTIONS.each_with_index do |question, index|
      params[:user][:description] += "#{question}\n" unless (index == 0 || params["description_#{index}"].empty?)
      params[:user][:description] += "#{params["description_#{index}"]}\r\n" unless params["description_#{index}"].empty?
    end
  end
end