class UsersController < ApplicationController

  before_filter :authenticate_user!, only: :update
  before_action :filter_param, only: :index

  def show
    @user = User.find(params[:id])
    @me = current_user
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @offers = @user.offers.order(:topic_group_id)
      @offers_single = @offers.group_by(&:topic_group_id).map{|topic_group, offers| offers.first if offers.count == 1}.compact
      @prices = @offers.map{ |d| d.offer_prices.map{ |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size unless @notes.empty?
      @profSimis = @user.similar_teachers(4)
      
      #Autres informations nécessaires pour l'application
      topics = Array.new
      offer_prices = Array.new
      levels = Array.new
      
      @offers.each do |ad|
        if ad.topic.title == "Other"
          topic_title = ad.other_name
        else
          topic_title = ad.topic.title
        end
        topics.push(topic_title)
        offer_prices.push(ad.offer_prices)
      end
      
      review_sender_names = Array.new
      @reviews.each do |review|
        review_sender_names.push(review.sender.firstname)
      end
          
      respond_to do |format|
        format.html {}
        format.json {render :json => {:avatar => @user.avatar.url(:medium), :offers => @offers, :offer_prices => offer_prices,
          :reviews => @reviews, :notes => @notes, :avg => @avg, :user => @user, :min_price => @user.min_price, 
          :topic_titles => topics, :review_sender_names => review_sender_names}}
      end
    else
      respond_to do |format|
        format.html {}
        format.json {render :json => {:user => @me, :avatar => @me.avatar.url(:medium)}}
      end
    end
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    search_sorting_options
    if params[:topic].nil? || params[:topic].empty?
      @search = User.where(:postulance_accepted => true).order(score: :desc).page(params[:page]).per(12)
      @pagin = @search
      search_text
    else
      # can't access global variable in sunspot search...
      @sunspot_search = Sunspot.search(Offer) do
        with(:postulance_accepted, true)
        fulltext search_text
        order_by(sorting, sorting_direction(params[:search_sorting]))
        group :user_id_str
        with(:first_lesson_free, true) if params[:filter] == 'first_lesson_free'
        with(:online, true) if params[:filter] == 'online'
        with(:has_reviews).greater_than(0) if params[:filter] == 'has_reviews'
        paginate(:page => params[:page], :per_page => 12)
      end
      @search = []
      @total = @sunspot_search.group(:user_id_str).total
      @sunspot_search.group(:user_id_str).groups.each do |group|
        group.results.each do |result|
          @search.push(result.user)
        end
      end
      @pagin = Kaminari.paginate_array(@search, total_count: @total, topic: @search_text).page(params[:page]).per(12)
    end
  end

  def profs_by_topic
    redirect_to profs_by_topic_path(params[:topic], params: params)
  end

  def both_users_online
    current = User.find(params[:user_current])
    other = User.find(params[:user_other])
    if current.online? && other.online?
      render :json => { :online => "true"}
    else
      render :json => { :online => "false"}
    end
  end

  def search_sorting_options
    @sorting_options = [["pertinence", "qwerteach_score"], ["prix", "min_price"], ["dernière connexion", "last_seen"]]
  end

  def sorting_direction(sort)
    case sort
      when "qwerteach_score"
        r = "desc"
      when "min_price"
        r = "asc"
      when "last_seen"
        r = "desc"
      else
        r = "desc"
    end
    r
  end

  def sorting
    if params[:search_sorting]
      @sorting_options.each do |option|
        return params[:search_sorting] if params[:search_sorting] == option[1]
      end
      "qwerteach_score"
    else
      "qwerteach_score"
    end
  end

  def search_text
    @topic = Topic.where('lower(title) = ?', params[:topic]).first
    if @topic.nil?
      @topic_group = TopicGroup.where('lower(title) = ?', params[:topic]).first
    end
    @search_topic ||= @topic || @topic_group
    unless @search_topic.nil?
      @search_text ||= @search_topic.title
    else
      @search_text ||= params[:topic]
    end
    if @search_text.nil? || @search_text.empty?
      @search_text = 'tous les profs'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Votre profil a bien été modifié"
      respond_to do |format|
        format.html {redirect_to edit_user_registration_path(@user)}
        format.json {render :json => {:user => @user, :success => "true", 
          :message => "Votre profil a bien été modifié."}}
      end and return
    else
      flash[:error] = "La modification a échoué"
      respond_to do |format|
        format.html {redirect_to edit_user_registration_path(@user)}
        format.json {render :json => {:user => @user, :success => "false", 
          :message => "La modification a échoué."}}
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:firstname, :lastname, :birthdate, :phone_country_code, :phone_number,
                                   :gender, :occupation, :description, :level_id,
                                   :time_zone, :avatar, :crop_x, :crop_y, :crop_h, :crop_w)
    end
  
    def filter_param
      @filter = params[:filter]
    end
end
