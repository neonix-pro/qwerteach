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
  
  def find_lesson_infos
    topic = Topic.find_by_id(params[:topic_id])
    topic_group = TopicGroup.find_by_id(params[:topic_group_id])
    level = Level.find_by_id(params[:level_id])
    lesson = Lesson.find_by_id(params[:lesson_id])
    user = User.find_by_id(params[:user_id])
    payment = Payment.find_by_lesson_id(params[:lesson_id])
    need_review = params[:need_review]
    
    if need_review
      student = User.find_by_id(lesson.student_id)
      review_needed = lesson.review_needed?(student)
    else
      review_needed = false
    end
    
    if level.nil?
      level_title = nil
    else
      level_title = level.fr
    end
    
    render :json => {:topic => topic.title, :topic_group => topic_group.title, :level => level_title, 
      :duration => lesson.duration, :expired => lesson.expired?, 
      :past => lesson.past?, :lesson_id => lesson.id, :payment_status => payment.status, :review_needed => review_needed,
      :user => {:firstname => user.firstname, :lastname => user.lastname}}
    
  end
  
end
