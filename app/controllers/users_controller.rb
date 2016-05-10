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
    #@users = @search.results
  end
end
