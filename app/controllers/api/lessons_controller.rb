class Api::LessonsController < LessonsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    lesson = Lesson.involving(@user)
    render :json => {:lessons => lesson}
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
  
  def find_lesson_infos
    topic = Topic.find_by_id(params[:topic_id])
    topic_group = TopicGroup.find_by_id(params[:topic_group_id])
    level = Level.find_by_id(params[:level_id])
    lesson = Lesson.find_by_id(params[:lesson_id])
    user = User.find_by_id(params[:user_id])
    
    render :json => {:topic => topic.title, :topic_group => topic_group.title, :level => level.fr, 
      :duration => lesson.duration, :expired => lesson.expired?, :lesson_id => lesson.id, 
      :user => {:firstname => user.firstname, :lastname => user.lastname}}
  end
  
end
