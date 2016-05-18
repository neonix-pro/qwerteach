class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @adverts = @user.adverts
      @prices = @adverts.map { |d| d.advert_prices.map { |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
    end
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    @search = Sunspot.search(Advert) do
      fulltext params[:q]
      order_by(:topic_id, "desc")
      with(:user_age).greater_than_or_equal_to(params[:age_min]) unless params[:age_min].blank?
      with(:user_age).less_than_or_equal_to(params[:age_max]) unless params[:age_max].blank?
      with(:advert_prices_truc).greater_than(params[:min_price]) unless params[:min_price].blank?
      with(:advert_prices_truc).less_than(params[:max_price]) unless params[:max_price].blank?
    end
    @h = Hash.new()
    @search.results.each do |x|
      if @h.assoc(x.user_id).nil?
        @h.store(x.user_id, Array.new)
      end
      @h[x.user_id].push(x)
    end
    if params[:degree_id].blank?
      @pagin = User.where(:id => @h.keys, :postulance_accepted => true).order(:level_id).page(params[:page]).per(15)
    else
      @pagin = User.where(:id => @h.keys, :postulance_accepted => true).where('level_id >= ?', params[:degree_id]).order(:level_id).page(params[:page]).per(15)
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
