class Api::LessonRequestsController < LessonRequestsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def new
    super
    respond_to do |format|
     format.json {render :json => {:success => "true", :lesson_request => @lesson_request.as_json}}
    end
  end
  
  def create
    super
  end
  
end
