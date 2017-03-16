class Api::ConversationsController < ConversationsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    messages = Array.new
    message_avatars = Array.new
    participant_avatars = Array.new
    
    @mailbox.conversations.each do |conv|
      conv.recipients.select{|participant| @user.id != participant.id}.each do |p|
        participant_avatars.push(p.avatar.url(:small))
      end
      conv.receipts_for(@user).each do |receipt|
        messages.push(receipt.message)
        message_avatars.push(receipt.message.sender.avatar.url(:small))
      end
    end
    render :json => {:participant_avatars => participant_avatars, :avatars => message_avatars, :recipients => @recipient_options, 
      :conversations => @conversations, :messages => messages}
  end
  
  def reply
    super
  end
  
  def show
    super
    render :json => {:last_message => @last_message}
  end
  
  def mark_as_read
    super
  end
  
end
