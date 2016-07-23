class UsersController < ApplicationController
  #before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @adverts = @user.adverts
      @prices = @adverts.map{ |d| d.advert_prices.map{ |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size unless @notes.empty?
    end
    @profSimis = @user.similar_teachers(4)
    @me = current_user
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    search_sorting_options
    if params[:topic].nil?
      @search = User.where(:postulance_accepted => true).order(score: :desc).page(params[:page]).per(12)
      @pagin = @search
    else
      # can't access global variable in sunspot search...
      topic = Topic.where('lower(title) = ?', params[:topic]).first
      if topic.nil?
        topic = TopicGroup.where('lower(title) = ?', params[:topic]).first
      end
      @sunspot_search = Sunspot.search(Advert) do
        with(:postulance_accepted, true)
        if topic.nil?
          fulltext params[:topic]
        else
          fulltext topic.title
        end
        order_by(sorting, sorting_direction(params[:search_sorting]))
        group :user_id_str
        with(:user_age).greater_than_or_equal_to(params[:age_min]) unless params[:age_min].blank?
        with(:user_age).less_than_or_equal_to(params[:age_max]) unless params[:age_max].blank?
        with(:advert_prices_search).greater_than(params[:min_price]) unless params[:min_price].blank?
        with(:advert_prices_search).less_than(params[:max_price]) unless params[:max_price].blank?
        with(:first_lesson_free, true) if params[:filter] == 'first_lesson_free'
        with(:online, true) if params[:filter] == 'online'
        with(:has_reviews).greater_than(0) if params[:filter] == 'has_reviews'
        paginate(:page => params[:page], :per_page => 12)
      end
      @search = []
      @total = @sunspot_search.group(:user_id_str).matches
      @sunspot_search.group(:user_id_str).groups.each do |group|
        group.results.each do |result|
          @search.push(result.user)
        end
      end
      if topic.nil?
        @topic_title = params[:topic]
      else
        @topic_title = topic.title
      end
      @pagin = Kaminari.paginate_array(@search, total_count: @total, topic: @topic_title).page(params[:page]).per(12)
      @topic = topic
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

end
