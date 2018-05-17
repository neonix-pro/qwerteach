class LessonPackAbility
  include CanCan::Ability

  def initialize(user)
    if user.is_a?(Teacher)
      can :create, LessonPack
      can :confirm, LessonPack
    end
    can %i[edit delete update propose destroy], LessonPack, teacher_id: user.id, status: %w[draft declined pending_student]
    can :show, LessonPack, student_id: user.id #, status: 'pending_student'
    can :show, LessonPack, teacher_id: user.id
    can [:pay, :payment, :finish_payment], LessonPack, student_id: user.id, status: 'pending_student'
    can :reject, LessonPack, student_id: user.id, status: 'pending_student'
  end
end