class ConversationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_user!
  before_action :get_mailbox
  before_action :get_conversation, except: [:index, :show_min, :find, :search]
  after_filter { flash.discard if request.xhr? }

  include Mailboxer
  MESSAGES_PER_PAGE = 10

  def index
    @user = current_user
    @mailbox_type = params[:mailbox].nil? ? 'inbox': params[:mailbox]
    @unread_count = @mailbox.inbox({:read => false}).count
    @conversations = @mailbox.conversations.page(params[:page]).per(MESSAGES_PER_PAGE)
    if current_user.is_admin?

    end
    @recipient_options = []
    @page = 1
    @messages = @conversations
                        .first
                        .messages
                        .page(@page)
                        .per(MESSAGES_PER_PAGE)
                        .order(id: :desc) if @conversations.present?
    respond_to do |format|
      format.html{}
      format.js{}
      format.json{}
    end
  end

  def trash
    @conversation = @mailbox.conversations.find(params[:id])
    set_result_flash @conversation.move_to_trash(current_user)
    refresh_mailbox
  end

  def untrash
    @conversation = @mailbox.conversations.find(params[:id])
    set_result_flash @conversation.untrash(current_user)
    refresh_mailbox
  end

  def mark_as_unread
    @conversation = @mailbox.conversations.find(params[:id])
    set_result_flash @conversation.mark_as_unread(current_user)
    refresh_mailbox
  end

  def mark_as_read
    set_result_flash @conversation.mark_as_read(current_user)
    respond_to do |format|
      format.html { redirect_to conversations_path }
      format.js{}
    end
  end

  def show
    @conversation.mark_as_read(current_user)
    @recievers = User.where(id: @conversation.receipts.group(:receiver_id).select(:receiver_id)).where.not(id: current_user.id)
    @page = params[:page] || 1
    @messages = @conversation.messages.page(@page).per(MESSAGES_PER_PAGE).order(id: :desc)
    @last_message = @messages.last
    @message = Mailboxer::Message.new
    #Resque.enqueue(MessageStatWorker, current_user.id)
    @unread_count = @mailbox.inbox({:read => false}).count
    @path = reply_conversation_path(@conversation)
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
    sending = SendMessage.run(reply_params)
    respond_to do |format|
      format.html do
        notice = sending.valid? ? I18n.t('message_pusher.validate.success') : sending.errors.full_messages.to_sentence
        redirect_to conversation_path(@conversation), notice: notice
      end
      format.js
      format.json { render json: {success: sending.valid?} }
    end
  end

  def find
    if params[:conversation_id].present?
      @conversation = current_user.mailbox.conversations.where(:id => params[:conversation_id])
    else
      recipients = [User.find(params[:recipient_id])]
      @conversation = current_user.mailbox.conversations.find do |c|
        (c.participants - recipients - [current_user]).empty? && (recipients - c.participants).empty?
      end
    end
    # TO DO: not neded anymore
    @conversation ||= current_user.send_message([current_user, (User.find(params[:recipient_id]))], "init_conv_via_chat", "chat").conversation
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


  private

  def set_result_flash(result)
    status = result ? :success : :danger
    flash[status] = I18n.t("conversation.#{action_name}.#{status}")
  end

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

  def reply_params
    {
      user: current_user,
      conversation_id: @conversation.id,
      body: params[:body]
    }
  end
end
