class OfferPricesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def edit
    @offerPrice = OfferPrice.find(params[:id])
  end
  def update
    @offerPrice = OfferPrice.find(params[:id])
    respond_to do |format|
      if (@offerPrice.level_id != params[:level_id])
        if (@offerPrice.offer.offer_prices.where(:level_id=>params[:level_id]).blank?)
          @offer.offer_prices.create(level_id: params[:level_id], offer_id: @offerPrice.offer.id, price: params[:price])
          format.html { redirect_to offers_path, notice: 'Price was successfully created.'}
          format.json { head :no_content }
        end
      end
      if @offerPrice.update_attributes(offer_price_params)
        format.html { redirect_to offers_path, notice: 'Price was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_offer_offer_price_path }
        format.json { render json: @offerPrice.errors, status: :unprocessable_entity }
      end
    end
  end
  def create
    @offerPrice = OfferPrice.new(offer_price_params)
    respond_to do |format|

      if @offerPrice.save
        format.js {redirect_to edit_offer_path(params[:offer_id])}
        format.html { redirect_to offers_path, notice: 'Price was successfully created.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_offer_offer_price_path }
        format.json { render json: @offerPrice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @offerPrice = OfferPrice.find(params[:id])
    @offerPrice.destroy
    respond_to do |format|
      params[:action]=nil
      format.js {redirect_to edit_offer_path(params[:offer_id]), status: 303}
    end
  end

  private
  def offer_price_params
    params.require(:offer_price).permit(:level_id, :price, :_destroy).merge(offer_id: params[:offer_id])
  end
end
