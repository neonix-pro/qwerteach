class UsersController < ApplicationController

  before_filter :authenticate_user!
  
  def show
    @user = User.find(params[:id])
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @adverts = @user.adverts
      @prices = @adverts.map { |d| d.advert_prices.map { |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size unless @notes.empty?
    end

    @profSimis = @user.similar_teachers(4)
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    if params[:q].nil?
      # pas d'infos entrées par le visiteur
      @pagin = User.where(:postulance_accepted => true).order(score: :desc).page(params[:page]).per(12)
    else
      # le visiteur a fait une requête
      @search = Sunspot.search(Advert) do
        fulltext params[:q]
        order_by(:topic_id, "desc")
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
    end
  end

  def both_users_online
    current = User.find(params[:user_current])
    other = User.find(params[:user_other])
    if current.last_seen > 10.minutes.ago && other.last_seen > 10.minutes.ago
      render :json => { :online => "true"}
    else
      render :json => { :online => "false"}
    end
  end

end
