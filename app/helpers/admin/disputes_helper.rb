module Admin
  module DisputesHelper

    BlankConversation = Struct.new(:id, :recipients, :count_messages, :messages)

    def disput_conversations(dispute)
      [
        conversation_between(current_user, dispute.student, dispute.teacher),
        conversation_between(current_user, dispute.student),
        conversation_between(current_user, dispute.teacher)
      ]
    end

    # Conversation between participants only
    def conversation_between(*users)
      conversation = SendMessage.conversation_between(*users)
      conversation || BlankConversation.new(nil, users - [current_user], 0, [])
    end
  end
end