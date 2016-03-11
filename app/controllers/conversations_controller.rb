class ConversationsController < ApplicationController
  before_filter :authenticate_user!

  # on ne veut pas que conversation hérite du layout application.html.erb
  # puisqu'on inclut cet morceau dans application.html
  layout false

  def create
    #Crée la converation si elle n'existe pas encore
    if Conversation.between(params[:sender_id],params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id],params[:recipient_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end
    #renvoie un json contenant uniquement l'id de la conversation
    render json: { conversation_id: @conversation.id }
  end

  def show
    @conversation = Conversation.find(params[:id])
    @reciever = interlocutor(@conversation)
    @messages = @conversation.messages
    @last_message = Message.find(@conversation.messages.last)
    @message = Message.new
  end

  private
  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end

  #récupère l'interlocuteur
  def interlocutor(conversation)
    current_user == conversation.recipient ? conversation.sender : conversation.recipient
  end
end