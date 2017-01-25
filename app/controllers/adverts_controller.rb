class AdvertsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  load_and_authorize_resource

  def index
    @adverts = Advert.where(:user => current_user)
    
    #Other informations for Qwerteach application
    topics = Array.new
    advert_prices = Array.new
    @adverts.each do |ad|
      if ad.topic.title == "Other"
        topic_title = ad.other_name
      else
        topic_title = ad.topic.title
      end
      topics.push(topic_title)
      advert_prices.push(ad.advert_prices)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => {:adverts => @adverts, :topic_titles => topics, 
        :advert_prices => advert_prices}}
    end
  end

  def show
    @advert = Advert.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json {render :json => {:advert => @advert, 
        :topic => @advert.topic.title, 
        :topic_group => @advert.topic.topic_group.title,
        :levels => find_levels(@advert.topic.topic_group.level_code)}}
    end
  end

  def new
    @advert = Advert.new
    respond_to do |format|
      format.html {}
      format.json { render json: @advert }
      format.js {}
    end
  end

  def edit
    @advert = Advert.find(params[:id])
    @levels = Level.where(:code => @advert.topic.topic_group.level_code).group(I18n.locale[0..3]).order(id: :asc)
    @advert_price = AdvertPrice.new(advert_price_params)
  end

  def create
    unless @user.is_a?(Teacher)
      @user.upgrade
    end
    if current_user.adverts.map(&:topic_id).include?(params[:topic_id].to_i)
      redirect_to adverts_path, notice: 'Une annonce pour cette catégorie existe déjà.' and return
    end
    @advert = Advert.new(advert_params)
    respond_to do |format|
      if @advert.save
        format.html { redirect_to adverts_path, notice: 'Advert was successfully created.' }
        format.json { head :no_content }
        format.js {}
      else
        logger.debug(puts @advert.errors.full_messages.to_sentence)
        format.html { redirect_to @advert, notice: 'Advert not created.' }
        format.json { render json: @advert.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @advert = Advert.find(params[:id])
    @advert.topic = Topic.find(params[:topic_id])
      if @advert.update_attributes!(advert_params)
        flash[:notice] = 'Vos modifications ont été sauvegardées.'
        
        respond_to do |format|
          format.html {redirect_to adverts_path, notice: 'Advert was successfully updated.'}
          format.json {render head => :no_content}
          format.js {}
        end and return
      else
        respond_to do |format|
          format.html {render action: "edit"}
          format.json {render json: @advert.errors, status: :unprocessable_entity}
        end
      end
  end

  def destroy
    @advert = Advert.find(params[:id])
    Advert.destroy(@advert.id)

    respond_to do |format|
      format.html { redirect_to adverts_url }
      format.json {render :json => {:success => "true"}}
      format.js {}
    end
  end

  def choice
    topic = Topic.find(params[:topic_id])
    @advert = Advert.find_by(user_id: current_user.id, topic_id: topic.id) || Advert.new()
    @levels = find_levels(topic.topic_group.level_code)
    respond_to do |format|
      format.js {}
    end
  end

  def choice_group
    group = TopicGroup.find(params[:group_id])
    @topics = Topic.where(:topic_group_id => group.id) - current_user.adverts.map(&:topic)
    respond_to do |format|
      format.js {}
    end
  end

  def get_all_adverts
    render json: User.where(:id => params[:user_id]).first.adverts.as_json(:include => {:topic => {:include => :topic_group}, :advert_prices => {:include => :level}}).to_json
  end


  private
  def advert_params
    params.require(:advert).permit(:description, :topic_id, :topic_group_id, advert_prices_attributes: [:id, :level_id, :price, :_destroy]).merge(user_id: current_user.id)
  end

  def advert_price_params
    params.permit(:advert).merge(advert: @advert)
  end

  def find_user
    @user = current_user
  end
  
  def find_levels(level_code)
    return Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '')
      .where(:code => level_code).group(I18n.locale[0..3]).order(:id)
  end
end
