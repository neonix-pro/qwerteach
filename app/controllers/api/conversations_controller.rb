class Api::ConversationsController < ConversationsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    @messages = Array.new
    @mailbox.conversations.each do |conv|
      conv.receipts_for(@user).each do |receipt|
        message = receipt.message
        @messages.push message
      end
    end
    render :json => {:messages => @messages, :conversations => @conversations, :recipients => @recipient_options}
  end
  
  def reply
    super
  end
  
  def show
    super
    render :json => {:last_message => @last_message}
  end
  
end
