class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :show_min, :find]

  def index
    @conversations = @mailbox.conversations.page(params[:page]).per(4)
  end

  private
  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def show
    @conversation = Mailboxer::Conversation.find(params[:conversation_id])
    @conversation.mark_as_read(current_user)
    @reciever = @conversation.participants - [current_user]
    @messages = @conversation.messages
    @last_message = @messages.last
    @message = Mailboxer::Message.new
  end

  private
  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_user)
  end

  public
  def reply
    conversation = current_user.reply_to_conversation(@conversation, params[:body]).conversation
    #flash[:success] = 'Reply sent'
    @path = reply_conversation_path(conversation)
    @message = conversation.messages.last
    PrivatePub.publish_to "/chat", :conversation_id => conversation.id, :receiver_id => (conversation.participants - [current_user]).first
    @conversation_id = conversation.id
    respond_to do |format|
      format.html {redirect_to conversation_path(conversation), notice: 'Reply sent'}
      format.js
    end
  end

  def find
    unless params[:conversation_id].blank?
      @conversation = current_user.mailbox.conversations.where(:id => params[:conversation_id])
      render json: {conversation_id: @conversation.id}
      return
    end
    if @conversation.nil?
      recipients = [User.find(params[:recipient_id])]
      current_user.mailbox.conversations.each do |c|
        if (c.participants - recipients - [current_user]).empty? && (recipients - c.participants).empty?
          @conversation = c
          render json: {conversation_id: @conversation.id}
          return
        end
      end
    end
    # Envoi fake msg pour init conversation avec participants
    @conversation = current_user.send_message([current_user, (User.find(params[:recipient_id]))], "init_conv_via_chat", "chat").conversation
    render json: {conversation_id: @conversation.id}
  end

  def show_min
    @conversation = Mailboxer::Conversation.find(params[:conversation_id])
    @conversation.mark_as_read(current_user)
    @reciever = @conversation.participants - [current_user]
    @messages = @conversation.messages
    @last_message = @messages.last
    @message = Mailboxer::Message.new
    render :layout => false
  end

  def interlocutor(conversation)
    current_user == conversation.recipient ? conversation.sender : conversation.recipient
  end

  def mark_as_read
    @conversation.mark_as_read(current_user)
    flash[:success] = 'The conversation was marked as read.'
    redirect_to conversations_path
  end
end
