module Admin
  module DisputesHelper

    def conversation_groups(lesson, user)
      conversations = [
        conversation([lesson.student,lesson.teacher, user]).merge({
          subject: t('dispute_message.group.common', default: 'Common')
        }),
        conversation([user, lesson.student]).merge({
          subject: t('dispute_message.group.student', default: 'Student')
        }),
        conversation([user, lesson.teacher]).merge({
          subject: t('dispute_message.group.teacher', default: 'Teacher')
        })
      ]
      Kaminari.paginate_array(conversations, total_count: 3).page(1).per(3)
    end

    private

    # Conversation between participants only
    def conversation(users)
      conversations = Conversation.between(*users.first(2)).to_a
      user_ids = users.map(&:id)
      conversation = conversations.find do |conv|
        conv.receipts.pluck(:receiver_id).all? {|id| user_ids.include?(id)}
      end
      (conversation || {}).as_json.merge(
        recipients: users,
        count_messages: conversation.try(:count_messages) || 0,
        messages: conversation.try(:messages) || []
      ).symbolize_keys
    end

  end
end