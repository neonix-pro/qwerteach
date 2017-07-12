# user              - message sender
# conversation_id   - ID of the conversation, if any; otherwise, a new
# recipient_ids     - ID recipients array, if no present conversation_id
# text              - message text
# subject           - message subject
class SendMessage < ActiveInteraction::Base

  Error = Class.new(StandardError)
  BodyToShortError = Class.new(Error)

  object :user, class: User

  integer :conversation_id, default: nil
  array :recipient_ids, default: nil
  string :body
  string :subject, default: nil

  validates :recipient_ids, :subject, presence: true, if: ->{ conversation_id.blank? }
  validate :recipients_not_only_self, if: ->{ conversation_id.blank? }

  def execute
    receipt = if conversation_id.present? or common_conversation_id.present?
                send_message_to_existen_conversation
              else
                raise BodyToShortError, I18n.t('send_message.validate.message') if body.size < 50
                send_message_to_new_conversation
              end
    send_notifications(receipt.conversation) and return receipt
  rescue BodyToShortError => e
    self.errors.add(:body, e.message)
  end

  def participants
    @participants ||= (recipients + [user]).uniq
  end

  def recipients
    @recipients ||= User.where(id: recipient_ids)
  end

  private

  def common_conversation_id
    @common_conversation_id ||= self.class.conversation_between(*participants).try(:id)
  end

  def recipients_not_only_self
    if (recipients - [user]).size.zero?
      errors.add :to_self, I18n.t('send_message.validate.to_self')
    end
  end

  def send_message_to_existen_conversation
    conversation = Mailboxer::Conversation.find(conversation_id || common_conversation_id)
    user.reply_to_conversation(conversation, body)
  end

  def send_message_to_new_conversation
    recipients = User.where(id: recipient_ids)
    user.send_message(recipients, body, subject)
  end

  def send_notifications(conversation)
    return unless errors.blank?
    message = conversation.last_message

    conversation.recipients.each do |receiver|
      next if receiver == user
      PrivatePub.publish_to(
        "/chat/#{receiver.id}",
        conversation_id: conversation.id,
        receiver_id: receiver.id
      )

      Pusher.notify(
        [receiver.id.to_s],
        {
          fcm: {
            notification: {
              title: message.subject,
              body: message.body,
              icon: 'androidlogo',
              click_action: 'MY_MESSAGES'
            }
          },
          webhook_url: 'http://requestb.in/wiriy8wi',
          webhook_level: 'DEBUG'
        }
      )
    end

    PrivatePub.publish_to(
      Rails.application.routes.url_helpers.reply_conversation_path(conversation),
      message_received: render_message(message, :received),
      message_sent: render_message(message, :sent),
      sender_id: user.id
    )

    Pusher.trigger(conversation.id.to_s, conversation.id.to_s,
      last_message: message,
      avatar: message.sender.avatar.url(:small)
    )

  end

  def render_message(message, type = :sent)
    ApplicationController.new.render_to_string(
      template: "messages/_message_#{type}.html.haml",
      locals: {message: message},
      layout: false)
  end


  def self.conversation_between(*users)
    conversation_ids = users.map{|u| u.mailbox.conversations.pluck(:id)}
    conversation_ids.inject(conversation_ids.first, :&).each do |id|
      conversation = Conversation.find(id)
      return conversation if (conversation.participants - users.uniq).blank?
    end
    nil
  end


end