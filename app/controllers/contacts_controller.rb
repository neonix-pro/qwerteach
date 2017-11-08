class ContactsController < ApplicationController
  before_action :save_phone_number, only: :entretien_pedagogique
  def new
    @contact = Contact.new
  end

  def create
    
    @contact = Contact.new(params[:contact])
    @contact.request = request
    if @contact.deliver
        
        flash[:notice] = 'Thank you fo your message!'
    
    elsif ScriptError
        flash[:danger] = 'Sorry, this message appears to be spam and was not delivered.'

    else
        
        flash[:danger] = 'Cannot send message.'
    render :new
    end
  end

  def entretien_pedagogique
    @contact = Contact.new(entretien_pedagogique_params)
    @contact.request = request
    if @contact.deliver
      flash[:notice] = 'Merci! Un membe de notre équipe vous contactera sous peu.'
    else
      flash[:danger] = "Désolé, il y a eu un problème avec votre requête. Celle-ci n'a pas été envoyée."
    end
    redirect_to root_path
  end

  def save_phone_number
    @user = current_user
    @user.phone_country_code = params[:phone_country_code]
    @user.phone_number = params[:phone_number]
    @user.save! if @user.valid_number?
    if !@user.valid_number?
      redirect_to root_path, flash: {danger: "Vous devez insérer un numéro de téléphone valide pour demander un entretien pédagogique"}
    end
  end

  private
  def entretien_pedagogique_params
    params.require(:contact).merge({
      subject: "Demande d'entretien pédagogique",
      message: merged_message,
      name: current_user.name,
      email: current_user.email,
      to: 'spanierity@gmail.com'

                                   }).permit(:subject, :message, :name, :email, :to)
  end

  def merged_message
     "#{params[:message]}  \n\r Téléphone: +#{params[:phone_country_code]}#{params[:phone_number]}"
  end

end
