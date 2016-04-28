class MessagesController < ApplicationController

  before_action :authenticate_user!

  def new
  end

  def create
    recipients = User.where(id: params['recipients'])
    current_user.mailbox.conversations.each do |c|
      if (c.participants - recipients - [current_user]).empty? && (recipients - c.participants).empty?
        conversation = current_user.reply_to_conversation(c, params[:message][:body]).conversation
        flash[:success] = "Reply sent!"
        redirect_to conversation_path(conversation)
        return
      end
    end
    conversation = current_user.send_message(recipients, params[:message][:body], params[:message][:subject]).conversation
    flash[:success] = "Message has been sent!"
    respond_to do |format|
      format.html { redirect_to conversation_path(conversation) }
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
