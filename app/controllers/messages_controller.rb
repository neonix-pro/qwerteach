class MessagesController < ApplicationController
  before_action :authenticate_user!
  after_filter { flash.discard if request.xhr? }
  before_action :get_conversation_and_reply_path, only: [:typing, :seen]

  def new
  end

  def create
    pushing = PushMessage.run(
      user: current_user,
      conversation_id: params[:message][:conversation_id].presence,
      recipient_ids: params[:message][:recipient].to_s.split,
      text: params[:message][:body],
      subject: params[:message][:subject]
    )
    status = (pushing.valid? && pushing.message).present?
    message_status = status ? I18n.t('message_pusher.validate.success') : pushing.errors.full_messages.to_sentence
    flash[status ? :success : :danger] = message_status
    respond_to do |format|
      format.html do
        way = params[:message].try(:[],:to_back) # request.referer
        redirect_to way.present? ? way : messagerie_path
      end
      format.js { render action: 'too_short' unless status }
      format.json { render :json => {success: status, message: message_status} }
    end
  end

  def typing
  end

  def seen
  end

  def count
    render json: current_user.mailbox.inbox({read: false}).count
  end

  private

  def get_conversation_and_reply_path
    @conversation =  Mailboxer::Conversation.find(params[:conversation_id])
    @path = reply_conversation_path(@conversation)
  end

end

