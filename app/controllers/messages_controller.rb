class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :get_conversation_and_reply_path, only: [:typing, :seen]

  def new
  end

  def create
    sending = SendMessage.run(send_params.merge(user: current_user))
    notice = sending.valid? ? I18n.t('send_message.validate.success') : sending.errors.full_messages.to_sentence
    respond_to do |format|
      format.html do
        flash[sending.valid? ? :success : :danger] = notice
        redirect_to params[:redirect_to].presence || messagerie_path
      end
      format.js { render action: 'too_short' unless status }
      format.json { render :json => {success: sending.valid?, message: notice} }
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

  def send_params
    params.require(:message).slice(:conversation_id, :body, :subject).tap do |p|
      p[:recipient_ids] = params[:message][:recipient].to_s.split.map(&:to_i)
    end.permit!
  end

end

