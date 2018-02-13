class Api::ConversationsController < ConversationsController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    super

    participant_avatars = Array.new
    recipients = Array.new
    @mailbox.conversations.each do |conv|
      recievers = User.where(id: conv.receipts.group(:receiver_id).select(:receiver_id)).where.not(id: current_user.id)
      if recievers.last.present?
        participant_avatars.push(recievers.last.avatar.url(:small))
        recipients.push(recievers.last)
      else
        participant_avatars.push(nil)
        recipients.push(nil)
      end
    end

    render :json => {:participant_avatars => participant_avatars, :recipients => recipients,
      :conversations => @mailbox.conversations, :messages => get_last_messages}

  end

  def reply
    super
  end

  def show
    super
    render :json => {:messages => @messages.reverse, :avatars => get_sender_avatars, :recipients => @recievers}
  end

  def mark_as_read
    super
  end

  def show_more
    super
    render :json => {:messages => @messages, :avatars => get_sender_avatars.reverse}
  end

  def get_last_messages
    last_messages = Array.new
    @mailbox.conversations.each do |conv|
      messages = conv.messages.page(@page).per(MESSAGES_PER_PAGE).order(id: :desc)
      last_messages.push(messages.reverse.last)
    end
    return last_messages
  end

  def get_sender_avatars
    sender_avatars = Array.new
    @messages.reverse.each do |receipt|
      if receipt.sender.present?
        sender_avatars.push(receipt.sender.avatar.url(:small))
      else
        sender_avatars.push(nil)
      end
    end
    return sender_avatars
  end

end
