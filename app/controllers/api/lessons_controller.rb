class Api::LessonsController < LessonsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    lesson = Lesson.involving(@user)
    render :json => {:lessons => lesson.as_json}
  end
  
  def cancel
    super
  end
  
  def update
    super
  end
  
  def find_topic_and_teacher
    topic = Topic.find_by_id(params[:topic_id])
    teacher = User.find_by_id(params[:teacher_id])
    lesson_id = params[:lesson_id]
    lesson = Lesson.find_by_id(lesson_id)
    duration = lesson.duration
    expired = lesson.expired?
    canceled = lesson.canceled?
    time_start = lesson.time_start.strftime('%d/%m/%Y à %H:%M')
    render :json => {:topic => topic.as_json, :teacher => teacher.as_json, 
      :lesson => {:lesson_id => lesson_id.as_json, :duration => duration.as_json, 
        :time_start => time_start.as_json, :expired => expired.as_json, :canceled => canceled.as_json}}
  end
  
end
