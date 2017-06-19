class Dispute < ActiveRecord::Base

  after_destroy { raise "Status is not complete! Status is '#{status}'." unless finished? }

  enum status: %i[started finished]

  belongs_to :user

  belongs_to :lesson # bbb_room, payments, topic_group, topic, level
  has_one :bbb_room, through: :lesson
  has_many :payments, through: :lesson

  #scope :opened, -> { where.not(status: statuses[:finished]) }

  def self.ransackable_scopes(auth_object)
    super + %i[started finished]
  end

  def conversation_groups(user)
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

  def conversation(user1, user2)
    Conversation.between(user1,user2).last
  end


end
