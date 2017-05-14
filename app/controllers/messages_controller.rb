class MessagesController < ApplicationController
  class SendToSelf < StandardError; end

  rescue_from SendToSelf, with: :dont_send_to_self

  before_action :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_action :check_users_different, only: :create

  def new
  end

  def dont_send_to_self(exception)
    flash[:notice]= "Vous ne pouvez pas envoyer de message à vous-même!"
    flash_to_headers
  end

  def create
    recipients = User.find(params[:message][:recipient])
    u1 = current_user
    u2 = recipients
    existing_conversation = Conversation.participant(u1).where('mailboxer_conversations.id in (?)', Conversation.participant(u2).collect(&:id))
    unless existing_conversation.empty?
      c = existing_conversation.first
      receipt = current_user.reply_to_conversation(c, params[:message][:body])
    else
      receipt = current_user.send_message([recipients], params[:message][:body], params[:message][:subject]) if params[:message][:body].length > 50
    end
    if receipt.nil?
      respond_to do |format|
        format.html {redirect_to messagerie_path}
        format.js {render action: 'too_short'}
        format.json {render :json => {:success => "false", :message => "Votre message est trop court!"}}
      end
    elsif  Mailboxer::Notification.successful_delivery?(receipt)
      flash[:success] = "Votre message a bien été envoyé!" unless params[:mailbox]
      respond_to do |format|
        format.html {redirect_to messagerie_path}
        format.js
        format.json {render :json => {:success => "true", :message => "Votre message a bien été envoyé!"}}
      end and return
    else
      flash[:danger] = "Votre message n'a pas pu être envoyé!"
      respond_to do |format|
        format.html {redirect_to messagerie_path}
        format.js {render action: 'too_short'}
        format.json {render :json => {:success => "false", :message => "Votre message n'a pas pu être envoyé!"}}
      end
    end
  end

  def typing
    @conversation =  Mailboxer::Conversation.find(params[:conversation_id])
    @path = reply_conversation_path(@conversation)
  end

  def seen
    @conversation =  Mailboxer::Conversation.find(params[:conversation_id])
    @path = reply_conversation_path(@conversation)
  end

  def count
    render :json => current_user.mailbox.inbox({:read => false}).count
  end

  private
    def check_users_different
      raise SendToSelf unless User.find(params[:message][:recipient]) != current_user
    end
end

