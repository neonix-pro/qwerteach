class Api::ProfilesController < UsersController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def display
    id = params[:user]["id"]
    user = User.find_by(id: id)
    if user.nil?
      warden.custom_failure!
      render :json => {:success => "false"}
    else
      age = user.age
      if not age.nil?
        render :json => {:success => "true", :user => user.as_json, :age => age}
        return
      else
        render :json => {:success => "true", :user => user.as_json}
        return
      end
    end
  end
  
  def find_level
    topic_group_level_code = "scolaire"
    level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:level => level.as_json}
  end
  
  def find_type
    user = User.find_by_id(params[:user]["id"])
    render :json => {:type => user.type}
  end
  
  def update
    super
  end
  
  def index
    super
  end
  
end
