class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.admin? # Admin user
      can :manage, :all
    else # Non-admin user
      can :create, Gallery
      can :read, Gallery
      can :update, Gallery, :user_id => user.id
      can :edit, Gallery, :user_id => user.id
      cannot :destroy, Gallery
      can :create, Picture
      can :read, Picture, :gallery => {:user_id => user.id}
      cannot :update, Picture
      can :destroy, Picture, :gallery => {:user_id => user.id}

      can :manage, Degree, :user_id => user.id
      cannot :create, Degree if user.type != "Teacher"

    
      can :create, Advert 
      can :create, AdvertPrice
      can :read, Advert 
      can :choice, Advert
      can :choice_group, Advert
      can :get_all_adverts, Advert

      can :read, AdvertPrice
      can :destroy, Advert, :user_id => user.id
      can :destroy, AdvertPrice, :advert => {:user_id => user.id}
      can :update, Advert, :user_id => user.id
      can :update, AdvertPrice, :advert => {:user_id => user.id}
      can :create, Degree if user.is_a? Teacher
      can :read, Degree, :user_id => user.id
      can :update, Degree, :user_id => user.id
      can :destroy, Degree, :user_id => user.id
      can :index, Payment, :user_id => user.id

      can :create_postpayment, Payment do |payment|
        payment.lesson.teacher_id == user.id
      end

      # seul le prof peut modifier les factures
      can :edit_postpayment, Payment do |payment|
        payment.postpayment? && payment.lesson.teacher_id == user.id
      end

      can :send_edit_postpayment, Payment do |payment|
        payment.postpayment? && payment.lesson.teacher_id == user.id
      end
      # seuls les participants peuvent voir un payement
      can :show, Payment do |payment|
        payment.lesson.teacher_id == user.id || payment.lesson.student_id == user.id
      end

      can :make_transfert, Payment

      can :send_make_transfert, Payment

      # TO DO: seul l'élève peut payer
      can :pay_postpayment, Payment do |payment|
        payment.lesson.student_id == user.id
      end

      can [:show_min, :show, :reply, :find, :mark_as_read], Conversation do |conversation|
        conversation.is_participant?(user)
      end
      
      #Seul le Student peut bloquer le paimentdu cours
      can :bloquerpayment, Payment do |payment|
        payment.lesson.student_id == user_id
      end
    end
  end
end

