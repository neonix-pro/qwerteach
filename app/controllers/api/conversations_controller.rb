class Api::ConversationsController < ConversationsController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    
    participant_avatars = Array.new
    @mailbox.conversations.each do |conv|
      conv.recipients.select{|participant| @user.id != participant.id}.each do |p|
        participant_avatars.push(p.avatar.url(:small))
      end
    end
    
    render :json => {:participant_avatars => participant_avatars, :recipients => @recipient_options, 
      :conversations => @conversations, :messages => get_last_messages}
    
  end
  
  def reply
    super
  end
  
  def show
    super
    render :json => {:messages => @messages.reverse, :avatars => get_sender_avatars, :recipients => @reciever}
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
      sender_avatars.push(receipt.sender.avatar.url(:small))
    end
    return sender_avatars
  end
  
end
