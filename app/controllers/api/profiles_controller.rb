class Api::ProfilesController < UsersController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def find_level
    topic_group_level_code = "scolaire"
    level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:levels => level.as_json}
  end
  
  def find_type
    user = User.find_by_id(params[:user]["id"])
    render :json => {:type => user.type}
  end
  
  def show
    super
  end
  
  def update
    super
  end
  
  def index
    super
    
    respond_to do |format|
      format.html {}
      format.json {render :json => {:pagin => @pagin, :options => @sorting_options}}
      format.js {}
    end
    
  end
  
end
