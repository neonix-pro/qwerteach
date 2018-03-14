class LessonPackAbility
  include CanCan::Ability

  def initialize(user)
    if user.is_a?(Teacher)
      can :index, LessonPack
      can :create, LessonPack
      can :confirm, LessonPack
    end
    can %i[show edit delete update propose], LessonPack, teacher_id: user.id, status: %w[draft declined]
    can :show, LessonPack, student_id: user.id, status: 'pending_student'
    can [:pay, :payment, :finish_payment], LessonPack, student_id: user.id, status: 'pending_student'
    can :reject, LessonPack, student_id: user.id, status: 'pending_student'
  end
end