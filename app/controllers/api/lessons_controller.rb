class Api::LessonsController < LessonsController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json

  def index
    super
    render :json => {:upcoming_lessons => @planned_lessons,
      :past_lessons => @history_lessons.select {|l| l.other(current_user).present?},
      :to_do_list => @pending_lessons}
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

  def index_pagination
    super
  end

  def find_lesson_informations
    lesson = Lesson.find_by_id(params[:lesson_id])

    render :json => {:topic => lesson.topic.title, :name => lesson.other(current_user).name,
      :avatar => lesson.other(current_user).avatar(:small), :payments => lesson.payments}
  end

end
