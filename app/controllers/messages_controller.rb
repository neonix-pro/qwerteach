class MessagesController < ApplicationController

  before_action :authenticate_user!
  after_filter { flash.discard if request.xhr? }

  def new
  end

  def create
    recipients = User.where(id: params['recipients'])
    current_user.mailbox.conversations.each do |c|
      if (c.participants - recipients - [current_user]).empty? && (recipients - c.participants).empty?
        conversation = current_user.reply_to_conversation(c, params[:message][:body]).conversation
        flash[:success] = "Votre message a bien été envoyé!"
        respond_to do |format|
          format.html {redirect_to messagerie_path}
          format.js {}
        end
        return
      end
    end
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Votre message a bien été envoyé."
    respond_to do |format|
      format.html { redirect_to messagerie_path }
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

