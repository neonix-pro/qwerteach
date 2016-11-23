class MessagesController < ApplicationController

  before_action :authenticate_user!
  after_filter { flash.discard if request.xhr? }

  def new
  end

  def create
    recipients = User.find(params[:message][:recipient])
    u1 = current_user
    u2 = recipients
    existing_conversation = Conversation.participant(u1).where('mailboxer_conversations.id in (?)', Conversation.participant(u2).collect(&:id))
    unless existing_conversation.empty?
      c = existing_conversation.first
      receipt = current_user.reply_to_conversation(c, params[:message][:body])
    else
      receipt = current_user.send_message([recipients], params[:message][:body], params[:message][:subject])
    end
    if Mailboxer::Notification.successful_delivery?(receipt)
      flash[:success] = "Votre message a bien été envoyé!" unless params[:mailbox]
    else
      flash[:danger] = "Votre message n'a pas pu être envoyé!"
    end
    respond_to do |format|
      format.html {redirect_to messagerie_path}
      format.js {
        redirect_to conversation_path(receipt.conversation)
      }
    end
  end

  def typing
    @conversation =  Mailboxer::Conversation.find(params[:conversation_id])
    @path = reply_conversation_path(@conversation)
  end

  def seen
    @conversation =  Mailboxer::Conversation.find(params[:conversation_id])
    @path = reply_conversation_path(@conversation)
end
end

