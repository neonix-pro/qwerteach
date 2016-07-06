class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :show_min, :find]

  def index
    @user = current_user
    params[:mailbox].nil? ? @mailbox_type = 'inbox': @mailbox_type = params[:mailbox]
    @unread_count = @mailbox.inbox({:read => false}).count

    case @mailbox_type
      when 'inbox'
        @conversations = @mailbox.inbox.page(params[:page]).per(10)
      when 'sentbox'
        @conversations = @mailbox.sentbox.page(params[:page]).per(10)
      when 'trash'
        @conversations = @mailbox.trash.page(params[:page]).per(10)
      else
        @conversations = @mailbox.inbox.page(params[:page]).per(10)
    end
    @online_buddies = []
    @mailbox.conversations.each do |conv|
      conv.participants.map{|u| @online_buddies.push(u.id) unless u.id == @user.id}
    end
    @online_buddies = User.where(:id=>@online_buddies).where(last_seen: (Time.now - 1.hour)..Time.now).order(last_seen: :desc).limit(10)
  end

  def show
    @conversation.mark_as_read(current_user)
    @reciever = @conversation.participants - [current_user]
    @messages = @conversation.messages
    @last_message = @messages.last
    @message = Mailboxer::Message.new
    Resque.enqueue(MessageStatWorker, current_user.id)
  end

  def reply
    conversation = current_user.reply_to_conversation(@conversation, params[:body]).conversation
    receiver = (conversation.participants - [current_user]).first
    @path = reply_conversation_path(conversation)
    @message = conversation.messages.last
    # notifie le gars qu'il a une conversation ==> permet d'ouvrir le chat automatiquement
    # Une fois qu'il a ouvert le chat, il subscribe au channel de la conversation
    PrivatePub.publish_to "/chat", :conversation_id => conversation.id, :receiver_id => receiver
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

  private
  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_user)
  end
  def get_mailbox
    @mailbox ||= current_user.mailbox
  end
end
