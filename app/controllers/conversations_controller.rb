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
    @mailbox_type = params[:mailbox].presence || 'inbox'
    @unread_count = @mailbox.inbox({read: false}).count
    @conversations = @mailbox.conversations
    @recipient_options = @mailbox.conversations.flat_map do |conv|
      conv.participants.map{|u| u unless u.nil? || u.id == @user.id}.compact
    end
    @online_buddies = User
                        .where(id: @recipient_options.map(&:id), last_seen: 1.hour.ago..Time.now)
                        .order(last_seen: :desc)
                        .limit(10)
    # @page = params[:page]
    @page = 1
    @messages = @conversations
                        .first
                        .messages
                        .page(@page)
                        .per(MESSAGES_PER_PAGE)
                        .order(id: :desc) if @conversations.present?
  end

  def trash
    @conversation = @mailbox.conversations.find(params[:id])
    set_flash @conversation.move_to_trash(current_user)
    refresh_mailbox
  end

  def untrash
    @conversation = @mailbox.conversations.find(params[:id])
    set_flash @conversation.untrash(current_user)
    refresh_mailbox
  end

  def mark_as_unread
    @conversation = @mailbox.conversations.find(params[:id])
    set_flash @conversation.mark_as_unread(current_user)
    refresh_mailbox
  end

  def mark_as_read
    set_flash @conversation.mark_as_read(current_user)
    respond_to do |format|
      format.html { redirect_to conversations_path }
      format.js{}
    end
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
    pushing = PushMessage.run(
      user: current_user,
      conversation_id: @conversation.id,
      text: params[:body],
      subject: @conversation.subject
    )
    status = (pushing.valid? && pushing.message).present?
    respond_to do |format|
      format.html do
        message_status = status ? I18n.t('message_pusher.validate.success') : pushing.errors.full_messages.to_sentence
        redirect_to conversation_path(@conversation), notice: message_status
      end
      format.js
      format.json { render json: {success: status} }
    end
  end

  def find
    if params[:conversation_id].present?
      @conversation = current_user.mailbox.conversations.where(:id => params[:conversation_id])
    else
      recipients = [User.find(params[:recipient_id])]
      current_user.mailbox.conversations.each do |c|
        if (c.participants - recipients - [current_user]).empty? && (recipients - c.participants).empty?
          @conversation = c
        end
      end
    end
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

  def set_flash(result)
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
end
