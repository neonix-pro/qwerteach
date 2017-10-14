class Api::UsersController < UsersController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def find_level 
    levels = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => "scolaire").group(I18n.locale[0..3]).order(:id)
    render :json => {:levels => levels}
  end
  
  def get_infos_for_detailed_prices_modal
    offer = Offer.find_by_id(params[:id])
    topic_group_title = offer.topic.topic_group.title
    prices = offer.offer_prices
    levels = []
    prices.each do |p|
      levels.push(p.level)
    end
    render :json => {:topic_group => topic_group_title, :levels => levels}
    
  end
  
  def show
    super
    if @user.is_a?(Teacher)
      topics = Array.new
      offer_prices = Array.new
      levels = Array.new
      review_sender_names = Array.new
      review_sender_avatars = Array.new
      
      @offers.each do |ad|
        if ad.topic.title == "Autre"
          topic_title = ad.other_name
        else
          topic_title = ad.topic.title
        end
        topics.push(topic_title)
        offer_prices.push(ad.offer_prices)
      end
      
      @reviews.each do |review|
        review_sender_names.push(review.sender.firstname) if review.sender
        review_sender_avatars.push(review.sender.avatar.url(:small)) if review.sender
      end
          
      respond_to do |format|
        format.html {}
        format.json {render :json => {:avatar => @user.avatar.url(:medium), :offers => @offers, :offer_prices => offer_prices,
          :reviews => @reviews, :notes => @notes, :avg => @avg, :user => @user, :min_price => @user.min_price, 
          :topic_titles => topics, :review_sender_names => review_sender_names, :avatars => review_sender_avatars}}
      end
      
    else
      respond_to do |format|
        format.html {}
        format.json {render :json => {:user => @me, :avatar => @me.avatar.url(:medium)}}
      end
    end
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
  
  def profs_by_topic
    super
  end
  
end
