module Admin
  module DisputesHelper

    def conversation_groups(lesson, user)
      @conversation_groups ||= {
          common: {
              recipient_ids: [lesson.student_id,lesson.teacher_id],
              conversation: Conversation.between(lesson.student,lesson.teacher).last, # As a rule one
          },
          student: {
              recipient_ids: [user.id, lesson.student_id],
              conversation: Conversation.between(user,lesson.student).last,
          },
          teacher: {
              recipient_ids: [user.id, lesson.teacher_id],
              conversation: Conversation.between(user,lesson.teacher).last
          }
      }
    end

    def message_class(message, dispute)
      case message.sender_id
        when dispute.user_id; then 'message-incoming alert-success'
        when current_user.id; then 'message-outgoing alert-warning'
        else 'message-incoming alert-info'
      end
    end

  end
end