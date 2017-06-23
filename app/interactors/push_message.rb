# user              - message sender
# conversation_id   - ID of the conversation, if any; otherwise, a new
# recipient_ids     - ID recipients array, if no present conversation_id
# text              - message text
# subject           - message subject
class PushMessage < ActiveInteraction::Base
  object :user, class: User
  integer :conversation_id, default: nil
  array :recipient_ids, default: nil
  string :text
  string :subject

  attr_reader :message, :conversation

  set_callback :validate, :before, :validate_recipients
  set_callback :validate, :before, :validate_length_text
  set_callback :validate, :before, :validate_send_to_self
  set_callback :execute, :before, :make_conversation_and_message

  def execute
    #return conversation if Rails.env.development?
    recipients.each do |receiver|
      PrivatePub.publish_to(
        "/chat/#{receiver.id}",
        conversation_id: conversation.id,
        receiver_id: receiver.id
      )
      PrivatePub.publish_to(
        Rails.application.routes.url_helpers.reply_conversation_path(conversation),
        message_received: string_received,
        message_sent: string_sent,
        sender_id: user.id
      )
      Pusher.trigger(conversation.id.to_s, conversation.id.to_s,
        last_message: message,
        avatar: message.sender.avatar.url(:small)
      )
      Pusher.notify(
        [receiver.id.to_s],
        {
          fcm: {
            notification: {
              title: message.subject,
              body: message.body,
              icon: 'androidlogo',
              click_action: 'MY_MESSAGES'}
          },
          webhook_url: 'http://requestb.in/wiriy8wi',
          webhook_level: 'DEBUG'
        }
      )
    end
    conversation
  end


  private

  def validate_recipients
    if conversation_id.nil? && (recipient_ids.blank? || recipient_ids.present? && User.where(id: recipient_ids).blank?)
      errors.add :recipients, I18n.t('message_pusher.validate.recipients')

    elsif conversation_id.present? && Conversation.find_by_id(conversation_id).nil?
      errors.add :conversation, I18n.t('message_pusher.validate.conversation')

    end
  end

  def validate_length_text
    if text.length <= 50
      # The first message can not be shorter than 50 characters
      return if conversation_id.present? && Conversation.find_by_id(conversation_id).present?
      errors.add :message, I18n.t('message_pusher.validate.message')
    end
  end

  def validate_send_to_self
    if recipient_ids.present? && (recipient_ids.map(&:to_i).uniq - [user.id]).count.zero?
      errors.add :to_self, I18n.t('message_pusher.validate.to_self')
    end
  end

  def make_conversation_and_message
    if conversation_id.present?
      @conversation = Conversation.find_by_id(conversation_id)
      @message = @conversation.messages.create(body: text, sender: user, subject: subject)
    else
      recipients = User.where(id: recipient_ids.first(2))
      user.send_message(recipients, text, subject)
      conversation = Conversation.between(*recipients).to_a
      user_ids = (recipient_ids + [user.id]).map(&:to_i).uniq
      @conversation = conversation.find do |conv|
        conv.receipts.pluck(:receiver_id).all? {|id| user_ids.include?(id)}
      end
      @message = @conversation.messages.last
    end
  end

  def string_received
    @string_received ||= ApplicationController.new.render_to_string(
      template: 'messages/_message_received.html.haml',
      locals: {message: message},
      layout: false
    )
  end

  def string_sent
    @string_sent ||= ApplicationController.new.render_to_string(
      template: 'messages/_message_sent.html.haml',
      locals: {message: message},
      layout: false
    )
  end

  def recipients
    conversation.participants - [user]
  end
end