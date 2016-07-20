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
    search_sorting_options
    search_topic_options
    if params[:topic].nil?
      @pagin = User.where(:postulance_accepted => true).order(score: :desc).page(params[:page]).per(12)
    else
      # can't access global variable in sunspot search...
      topic = Topic.where('lower(title) = ?', params[:topic]).first
      if topic.nil?
        topic = TopicGroup.where('lower(title) = ?', params[:topic]).first
      end
      @search = Sunspot.search(Advert) do
        with(:postulance_accepted, true)
        fulltext topic.title
        order_by(sorting, sorting_direction(params[:search_sorting]))
        group :user_id_str
        with(:user_age).greater_than_or_equal_to(params[:age_min]) unless params[:age_min].blank?
        with(:user_age).less_than_or_equal_to(params[:age_max]) unless params[:age_max].blank?
        with(:advert_prices_search).greater_than(params[:min_price]) unless params[:min_price].blank?
        with(:advert_prices_search).less_than(params[:max_price]) unless params[:max_price].blank?
        paginate(:page => params[:page], :per_page => 12)
      end
      @pagin = []
      @search.group(:user_id_str).groups.each do |group|
        group.results.each do |result|
          @pagin.push(result.user)
        end
      end
      @topic = topic
    end
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
      params[:search_sorting]
    else
      "qwerteach_score"
    end
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
      # when 6
      #   profil_advert_classes(2) + profil_advert_classes(1) + profil_advert_classes(3)
      # when 7
      #   profil_advert_classes(2) + profil_advert_classes(3) + profil_advert_classes(2)
      # when 8
      #   profil_advert_classes(2) + profil_advert_classes(3) + profil_advert_classes(3)
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
