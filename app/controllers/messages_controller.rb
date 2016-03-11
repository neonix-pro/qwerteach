class MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user_id = current_user.id
    @message.save!
    
    PrivatePub.publish_to "/notifications", :conversation_id => @conversation.id, :receiver_id => @conversation.recipient_id
    @path = conversation_path(@conversation)
  end

  def typing
     @conversation = Conversation.find(params[:conversation_id])
     @path = conversation_path(@conversation)
  end
  def seen
    @conversation = Conversation.find(params[:conversation_id])
    @last_message = Message.find(@conversation.messages.last.id)
    @messages = @conversation.messages
    @messages.unread_by(current_user).each do |msg|
      logger.debug("MSG : " + msg.id.to_s)
      msg.mark_as_read! :for => current_user
    end
    @reciever = (@last_message.user == @conversation.recipient ? @conversation.sender : @conversation.recipient)
    @sender = (@last_message.user == @conversation.sender ? @conversation.sender : @conversation.recipient)
    PrivatePub.publish_to "/notifications", :conversation_id => @conversation.id, :receiver_id => @conversation.recipient_id
    @path = conversation_path(@conversation)
  end
  private
  def message_params
    params.require(:message).permit(:body)
  end
end