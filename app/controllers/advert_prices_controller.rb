class AdvertPricesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def edit
    @advertPrice = AdvertPrice.find(params[:id])
  end
  def update
    @advertPrice = AdvertPrice.find(params[:id])
    respond_to do |format|
      if (@advertPrice.level_id != params[:level_id])
        if (@advertPrice.advert.advert_prices.where(:level_id=>params[:level_id]).blank?)
          @advert.advert_prices.create(level_id: params[:level_id], advert_id: @advertPrice.advert.id, price: params[:price])
          format.html { redirect_to adverts_path, notice: 'Price was successfully created.'}
          format.json { head :no_content }
        end
      end
      if @advertPrice.update_attributes(advert_price_params)
        format.html { redirect_to adverts_path, notice: 'Price was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_advert_advert_price_path }
        format.json { render json: @advertPrice.errors, status: :unprocessable_entity }
      end
    end
  end
  def create
    @advertPrice = AdvertPrice.new(advert_price_params)
    respond_to do |format|

      if @advertPrice.save
        format.js {redirect_to edit_advert_path(params[:advert_id])}
        format.html { redirect_to adverts_path, notice: 'Price was successfully created.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_advert_advert_price_path }
        format.json { render json: @advertPrice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @advertPrice = AdvertPrice.find(params[:id])
    @advertPrice.destroy
    respond_to do |format|
      params[:action]=nil
      format.js {redirect_to edit_advert_path(params[:advert_id]), status: 303}
    end
  end

  private
  def advert_price_params
    params.require(:advert_price).permit(:level_id, :price, :_destroy).merge(advert_id: params[:advert_id])
  end
end
