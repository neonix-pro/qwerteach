class Api::AdvertsController < AdvertsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
  end
  
  def update
    super
  end
  
  def show
    super
  end
  
  def destroy
    super
  end
    
  
  def create
    user_id = params[:advert]["id"]
    topic_group_id = params[:advert]["topic_group_id"]
    topic_id = params[:advert]["topic_id"]
    other_name = params[:advert]["other_name"]
    unless Advert.where(user_id: user_id).where(topic_id: topic_id).where(topic_group_id: topic_group_id).where(other_name: other_name).empty?
      render :json => {:success => "exists"}
      return
    else
      if params[:advert]["advert_price"]
        advert = Advert.new
        advert.user_id = user_id
        advert.topic_id = topic_id
        advert.topic_group_id = topic_group_id
        advert.other_name = other_name
        advert.description = params[:advert]["description"]
        if advert.save
          jsonArray = params[:advert]["advert_price"]
          jsonArray.each do |object|
            advert_price = AdvertPrice.new
            advert_price.advert_id = advert.id
            advert_price.level_id = object["level_id"]
            advert_price.price = object["price"]
            advert_price.save
          end
          render :json => {:success => "true"}
          return
        else
          render :json => {:success => "false"}
          return
        end
      else
        render :json => {:success => "need"}
        return
      end
    end
  end
  
end
