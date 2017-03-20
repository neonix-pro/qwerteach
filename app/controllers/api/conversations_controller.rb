class Api::ConversationsController < ConversationsController
  
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
    
    render :json => {:participant_avatars => participant_avatars, :avatars => get_sender_avatars, 
      :recipients => @recipient_options, :conversations => @conversations, :messages => @messages.reverse}
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
  
  def show_more
    super
    render :json => {:messages => @messages, :avatars => get_sender_avatars.reverse}
  end
  
  def get_sender_avatars
    sender_avatars = Array.new
    @messages.reverse.each do |receipt|
      sender_avatars.push(receipt.sender.avatar.url(:small))
    end and return sender_avatars
  end
  
end
