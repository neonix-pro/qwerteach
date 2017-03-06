class Api::UsersController < UsersController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def find_level
    topic_group_level_code = "scolaire"
    level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:levels => level}
  end
  
  def get_infos_for_detailed_prices_modal
    advert = Advert.find_by_id(params[:id])
    topic_group_title = advert.topic.topic_group.title
    prices = advert.advert_prices
    levels = []
    prices.each do |p|
      levels.push(p.level)
    end
    render :json => {:topic_group => topic_group_title, :levels => levels}
    
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
