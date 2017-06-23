class Api::LessonRequestsController < LessonRequestsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def new
    super
  end
  
  def create
    super
  end
  
  def payment
    super
  end
  
  def bancontact_process
    super
  end
  
  def credit_card_process
    super
  end
  
  def topics
    super
  end
  
  def levels
    levels = []
    @teacher.offers.where(topic_id: params[:topic_id]).each do |offer|
      offer.offer_prices.each do |p|
        levels.push(p.level)
      end
    end
    render :json => {:levels => levels}
  end
  
  def topic_groups
    topic_groups = []
    @teacher.offers.includes(:topic_group).each do |tg|
      topic_groups.push(tg.topic_group)
    end
    render :json => {:topic_groups => topic_groups.uniq}
  end
  
end
