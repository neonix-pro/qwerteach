class AdvertsController < ApplicationController

  def index
    @adverts = Advert.where(:user=>current_user).group(:title)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @adverts }
    end
  end

  def show
    @advert = Advert.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @advert }
    end
  end

  def new
    @advert = Advert.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @advert }
    end
  end

  def edit
    @advert = Advert.find(params[:id])
  end

  def create
    @advert = Advert.new(advert_params)
    respond_to do |format|
      if @advert.save
        if params[:levels_chosen]
          cpt = 0;
          params[:levels_chosen].each { |level|
            p = params[:prices][cpt.to_i]
            while (p.nil?)
              p = params[:prices][cpt.to_i]
              cpt+=1
            end
            @advert.advert_prices.create(level_id: level, advert_id: @advert.id, price: p)
          }
        end
        format.html { redirect_to adverts_path, notice: 'Advert was successfully created.'}
        format.json { head :no_content }
      else
        format.html { redirect_to @advert, notice: 'Advert not created.'}
        format.json { render json: @advert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @advert = Advert.find(params[:id])
    respond_to do |format|
      if @advert.update_attributes(advert_params)
        @price = @advert.advert_prices.last
        format.html { redirect_to edit_advert_advert_price_path(:id=> @price.id, :advert_id=>@advert.id), notice: 'Advert was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @advert.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @advert = Advert.find(params[:id])
    @advert.destroy

    respond_to do |format|
      format.html { redirect_to adverts_url }
      format.json { head :no_content }
    end
  end

  private
  def advert_params
    params.require(:advert).permit(:topic_id, :user_id, advert_prices_attributes: [:level_id, :price] ).merge(user_id: current_user.id)
  end
end
