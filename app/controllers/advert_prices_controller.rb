class AdvertPricesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def edit
    @advertPrice = AdvertPrice.find(params[:id])
  end
  def update
    @advertPrice = AdvertPrice.find(params[:id])
    respond_to do |format|
      logger.debug('************** APPPP')
      if (@advertPrice.level_id != params[:level_id])
        if (@advertPrice.advert.advert_prices.where(:level_id=>params[:level_id]).blank?)
          @advert.advert_prices.create(level_id: params[:level_id], advert_id: @advertPrice.advert.id, price: params[:price])
          format.html { render adverts_path, notice: 'Price was successfully created.'}
          format.json { head :no_content }
        end
      end
      if @advertPrice.update_attributes(advertPrice_params)
        format.html { render adverts_path, notice: 'Price was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_advert_advert_price_path }
        format.json { render json: @advertPrice.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    @advertPrice = AdvertPrice.new(advertPrice_params)
    respond_to do |format|

      if @advertPrice.save
        format.html { render adverts_path, notice: 'Price was successfully created.'}
        format.json { head :no_content }
      else
        format.html { render action: edit_advert_advert_price_path }
        format.json { render json: @advertPrice.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def advertPrice_params
    params.require(:advert_price).permit(:advert_id, :level_id, :price, :_destroy)
  end
end
