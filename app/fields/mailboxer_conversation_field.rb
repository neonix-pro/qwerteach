require "administrate/field/base"

class MailboxerConversationField < Administrate::Field::Base
  def to_s

    data
  end

  def index
    @conversations = Mailboxer::Conversation.all.map{|t| t.participants.include?(data) ? t.id : nil}
    @self = data
    @conversations
  end

end
