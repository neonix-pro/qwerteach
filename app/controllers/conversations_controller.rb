class ConversationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :show_min, :find, :search]
  after_filter { flash.discard if request.xhr? }

  include Mailboxer
  MESSAGES_PER_PAGE = 20

  def index
    @user = current_user
    params[:mailbox].nil? ? @mailbox_type = 'inbox': @mailbox_type = params[:mailbox]
    @unread_count = @mailbox.inbox({:read => false}).count
    case @mailbox_type
      when 'inbox'
        @conversations = @mailbox.conversations
      else
        @conversations = @mailbox.conversations
    end
    @recipient_options = []
    @mailbox.conversations.each do |conv|
      conv.participants.map{|u| @recipient_options.push(u) unless u.nil? || u.id == @user.id}
    end
    @online_buddies = User.where(:id=>@recipient_options.map(&:id)).where(last_seen: (Time.now - 1.hour)..Time.now).order(last_seen: :desc).limit(10)
    @page = 1
    @messages = @conversations.first.messages.page(@page).per(MESSAGES_PER_PAGE).order(id: :desc) unless @conversations.empty?
  end

  def trash
    @conversation = @mailbox.conversations.find(params[:id])
    if @conversation.move_to_trash(current_user)
      flash[:success] = 'La conversation a bien été placée dans votre corbeille'
    else
      flash[:danger] = 'il y a eu un problème, la conversation n\'a pas pu être supprimée.'
    end
    refresh_mailbox
  end

  def untrash
    @conversation = @mailbox.conversations.find(params[:id])
    if @conversation.untrash(current_user)
      flash[:success] = 'La conversation a bien été déplacée vers votre boîte de réception'
    else
      flash[:danger] = 'il y a eu un problème, la conversation n\'a pas pu être déplacée.'
    end
    refresh_mailbox
  end

  def mark_as_unread
    @conversation = @mailbox.conversations.find(params[:id])
    if @conversation.mark_as_unread(current_user)
      flash[:success] = 'La conversation a bien été marquée comme non lue'
    else
      flash[:danger] = 'il y a eu un problème, l\'opération n\'a pas pu être effectuée.'
    end
    refresh_mailbox
  end

  def show
    @conversation.mark_as_read(current_user)
    @reciever = @conversation.participants - [current_user]
    @page = params[:page] || 1
    @messages = @conversation.messages.page(@page).per(MESSAGES_PER_PAGE).order(id: :desc)
    @last_message = @messages.last
    @message = Mailboxer::Message.new
    Resque.enqueue(MessageStatWorker, current_user.id)
    @unread_count = @mailbox.inbox({:read => false}).count
    @path = reply_conversation_path(@conversation)
    Rails.logger.debug("RECIEVER: #{@reciever.inspect}")
  end

  def show_more
    @page = params[:page] || 1
    @messages = @conversation.messages.page(@page).per(MESSAGES_PER_PAGE).order(id: :desc)
  end

  def search
    @user = current_user
    @conversations = @user.search_messages(params[:q])
  end

  def reply
    conversation = @conversation
    receipt = current_user.reply_to_conversation(conversation, params[:body])
    receiver = (@conversation.participants - [current_user]).first
    @path = reply_conversation_path(@conversation)
    @message = @conversation.messages.last
    # notifie le gars qu'il a une conversation ==> permet d'ouvrir le chat automatiquement
    # Une fois qu'il a ouvert le chat, il subscribe au channel de la conversation

    @string_received = render_to_string template: 'messages/_message_received.html.haml', locals:{message: @message}, layout: false
    @string_sent = render_to_string template: 'messages/_message_sent.html.haml', locals:{message: @message}, layout: false


    PrivatePub.publish_to "/chat/#{receiver.id}", :conversation_id => @conversation.id, :receiver_id => receiver
    PrivatePub.publish_to @path, message_received: @string_received, message_sent: @string_sent, sender_id: current_user.id
    
    #Send message to android app
    Pusher.trigger("#{@conversation.id}", "#{@conversation.id}", {last_message: @message, avatar: @message.sender.avatar.url(:small)})
    
    #Send notification to android app
    Pusher.notify(["#{receiver.id}"], {fcm: {notification: {title: "Nouveau message sur Qwerteach", body: @message.body,
      icon: 'androidlogo', click_action: "MY_MESSAGES"}}, webhook_url: 'http://requestb.in/wiriy8wi', webhook_level: 'DEBUG'})
    
    @conversation_id = @conversation.id
    respond_to do |format|
      format.html {redirect_to conversation_path(@conversation), notice: 'Reply sent'}
      format.js
      format.json {render :json => {:success => "true"}}
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
  
    # TO DO: not neded anymore
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
    respond_to do |format|
      format.html{
        flash[:success] = 'The conversation was marked as read.'
        redirect_to conversations_path
      }
      format.js{}
    end
  end

  private
  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
    @conversation.mark_as_read(current_user)
  end
  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def refresh_mailbox
    index
    respond_to do |format|
      format.js {render :index}
      format.html {}
    end
  end
end
