class AdvertsController < ApplicationController
  before_filter :authenticate_user!
  
  load_and_authorize_resource

  def index
    @adverts = Advert.where(:user => current_user)

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
        @advert.topic = Topic.find(params[:topic_id])
        if params[:levels_chosen]
          cpt = 0;
          p = params[:prices][cpt.to_i]
          params[:levels_chosen].each { |level|
            while (p.blank?)
              cpt+=1
              p = params[:prices][cpt.to_i]
            end
            @advert.advert_prices.create(level_id: level, advert_id: @advert.id, price: p)
            cpt+=1
            p = params[:prices][cpt.to_i]
          }
        end

        format.html { redirect_to adverts_path, notice: 'Advert was successfully created.' }
        format.json { head :no_content }
        format.js {}

      else
        format.html { redirect_to @advert, notice: 'Advert not created.' }
        format.json { render json: @advert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @advert = Advert.find(params[:id])
    @advert.topic = Topic.find(params[:topic_id])

    respond_to do |format|
      if @advert.update_attributes(advert_params)
        if params[:levels_chosen]
          cpt = 0;
          p = params[:prices][cpt.to_i]
          params[:levels_chosen].each { |level|
            while (p.blank?)
              cpt+=1
              p = params[:prices][cpt.to_i]
            end
            if (@advert.advert_prices.where(:level_id => level).blank?)
              @advert.advert_prices.create(level_id: level, advert_id: @advert.id, price: p)
            end
            cpt+=1
            p = params[:prices][cpt.to_i]
          }
        end

        format.html { redirect_to adverts_path, notice: 'Advert was successfully updated.' }
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
      format.json { }
      format.js {}
    end
  end

  def choice
    topic = Topic.find(params[:topic_id])
    level_choice = topic.topic_group.level_code
    @levels = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => level_choice).group(I18n.locale[0..3]).order(:id)
    respond_to do |format|
      format.js {}
    end
  end

  def choice_group
    group = TopicGroup.find(params[:group_id])
    @topics = Topic.where(:topic_group => group)
    respond_to do |format|
      format.js {}
    end
  end

  private
  def advert_params
    params.require(:advert).permit(:topic_id, :user_id, :other_name, :topic, advert_prices_attributes: [:id, :level_id, :price, :_destroy]).merge(user_id: current_user.id, topic: Topic.find(params[:topic_id]))
  end
end
