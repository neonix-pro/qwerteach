class Api::LessonsController < LessonsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    render :json => {:lessons => @lessons} 
  end
  
  def cancel
    super
  end
  
  def update
    super
  end
  
  def refuse
    super
  end
  
  def accept
    super
  end
  
  def pay_teacher
    super
  end
  
  def dispute
    super
  end
  
  def find_lesson_informations
    lesson = Lesson.find_by_id(params[:lesson_id])
    todo = lesson.todo(current_user)
    
    case todo
      when :wait
      if lesson.past?
        lesson_status = "past"
      else
        if lesson.pending?
          lesson_status = "waiting"
        else
          lesson_status = "accepted"
        end
      end
      when :inactive
      if lesson.expired?
        lesson_status = "expired"
      elsif lesson.canceled?
        lesson_status = "canceled"
      elsif lesson.refused?
        lesson_status = "refused"
      end
      when :confirm
      lesson_status = "confirm"
      when :unlock
      lesson_status = "pay"
      when :review
      lesson_status = "review"
      when :disputed
      lesson_status = "disputed"
      when nil
      lesson_status = "past&paid"
    end
    
    if lesson.level.nil?
      level_title = nil
    else
      level_title = lesson.level.fr
    end
    
    render :json => {:topic => lesson.topic.title, 
      :topic_group => lesson.topic_group.title, 
      :level => level_title, 
      :duration => lesson.duration,
      :name => lesson.other(current_user).firstname, 
      :lesson_status => lesson_status,
      :avatar => lesson.other(current_user).avatar(:medium),
      :payments => lesson.payments}
    
  end
  
end
