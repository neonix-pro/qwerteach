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
    @profil_advert_classes = profil_advert_classes(@adverts.count)
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    logger.debug(params)
    logger.debug('-----------')
    search_sorting_options
    search_sorting_name
    search_topic_options
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
        paginate(:page => params[:page], :per_page => 12)
      end
      @search = []
      @total = 0
      @sunspot_search.group(:user_id_str).groups.each do |group|
        @total += group.total
        group.results.each do |result|
          @search.push(result.user)
        end
      end
      @pagin = Kaminari.paginate_array(@search, total_count: @total, topic: topic.title).page(params[:page]).per(12)
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

  def search_topic_options
    @topic_options = Topic.where.not(:title=> "Other").map{|p| [p.title.downcase]}
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

  def search_sorting_name
    @sorting_options.each do |sort|
      return @sorting_name =  sort[0] if sort[1] == params[:search_sorting]
    end
    @sorting_name = "pertinence"
  end

  def profil_advert_classes(n)
    case n
      when 1
        ['simple']
      when 2
        ['double', 'double']
      when 3
        ['simple', 'double', 'double']
      when 4
        ['simple', 'triple', 'triple', 'triple']
      when 5
        ['double', 'double', 'triple', 'triple', 'triple']
      else
        r= profil_advert_classes(2)
        c = n - 2
        while c > 0
          t = rand(1..[5, c].min)
          r += profil_advert_classes(t)
          c -= t
        end
        r
    end
  end

end
