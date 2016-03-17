class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :new, :show_min, :find]

  def index
    @conversations = @mailbox.conversations.page(params[:page]).per(4)
  end

  private
  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def show
  end

  private
  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
  end

  public
  def reply
    conversation = current_user.reply_to_conversation(@conversation, params[:body]).conversation
    flash[:success] = 'Reply sent'
    redirect_to conversation_path(conversation)
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
    @conversation = @mailbox.conversations.create(:subject => "chat")
    render json: {conversation_id: @conversation.id}
  end

  def show_min
    @conversation = Mailboxer::Conversation.find(params[:conversation_id])
    @reciever = @conversation.participants - [current_user]
    @messages = @conversation.messages
    @last_message = @messages.last
    @message = Mailboxer::Message.new
    render :layout => false

  end

  def interlocutor(conversation)
    current_user == conversation.recipient ? conversation.sender : conversation.recipient
  end
end
