class OffersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  after_filter { flash.discard if request.xhr? }

  load_and_authorize_resource

  def index
    @offers = Offer.where(:user => current_user)
    
    #Other informations for Qwerteach application
    topics = Array.new
    offer_prices = Array.new
    @offers.each do |offer|
      if offer.topic.title == "Autre"
        topic_title = offer.other_name
      else
        topic_title = offer.topic.title
      end
      topics.push(topic_title)
      offer_prices.push(offer.offer_prices)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => {:offers => @offers, :topic_titles => topics, 
        :offer_prices => offer_prices}}
    end
  end

  def show
    @offer = Offer.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json {render :json => {:offer => @offer, 
        :topic => @offer.topic.title, 
        :topic_group => @offer.topic.topic_group.title,
        :levels => find_levels(@offer.topic.topic_group.level_code)}}
    end
  end

  def new
    @offer = Offer.new
    respond_to do |format|
      format.html {}
      format.json { render json: @offer }
      format.js {}
    end
  end

  def edit
    @offer = Offer.find(params[:id])
    @levels = Level.where(:code => @offer.topic.topic_group.level_code).group(I18n.locale[0..3]).order(id: :asc)
    @offer_price = OfferPrice.new(offer_price_params)
  end

  def create
    @user = current_user
    unless @user.is_a?(Teacher)
      @user.upgrade
    end
    if current_user.offers_except_other.map(&:topic_id).include?(params[:offer][:topic_id].to_i)
      respond_to do |format|
        flash[:notice]='Une annonce pour cette catégorie existe déjà.'
        format.html {redirect_to edit_user_registration_path(@user) + '#offers'}
        format.js {}
        format.json {render :json => {:success => "true", :message => 'Une annonce pour cette catégorie existe déjà.'}}
        return
      end
    end

    @offer = Offer.new(offer_params)
    respond_to do |format|
      if @offer.save
        format.html {redirect_to edit_user_registration_path(@user) + '#offers', notice: 'Votre annonce a bien été enregistrée.'}
        format.json {render :json => {:success => "true"}}
        format.js {render partial: "#{params[:origin]}/create_offer", locals: {offer: @offer} if params[:origin]}
      else
        logger.debug('-------'*10)
        format.html {
          flash[:danger]="Il y a eu un problème, votre annonce, n'a pas été mise à jour: #{@offer.errors.full_messages.to_sentence}"
          redirect_to @offer
        }
        format.json {render :json => {:success => "false", :message => @advert.errors}, :status => :unprocessable_entity}
        format.js {flash[:danger]=@offer.errors.full_messages.to_sentence}
      end
    end
  end

  def update
    @offer = Offer.find(params[:id])
    @offer.topic = Topic.find(params[:topic_id])
    respond_to do |format|
      if @offer.update_attributes!(offer_params)
        flash[:notice] = 'Vos modifications ont été sauvegardées.'
        format.html { redirect_to edit_user_registration_path(@user) + '#offers'}
        format.json {render :json => {:success => "true", :message => 'Vos modifications ont été sauvegardées.'}}
        format.js {}
      else
        format.html { render action: "edit" }
        format.json {render :json => {:success => "false", :message => @advert.errors}, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @offer = Offer.find(params[:id])
    Offer.destroy(@offer.id)
    respond_to do |format|
      format.html { redirect_to params[:origin].nil? ? edit_user_registration_path(@offer.user_id) : "/#{params[:origin]}/offers"}
      format.json {render :json => {:success => "true"}}
      format.js {}
    end
  end

  def choice
    topic = Topic.find(params[:topic_id])
    level_choice = topic.topic_group.level_code
    params.has_key?(:id) ? @offer = Offer.find_by(user_id: current_user.id, topic_id: topic.id) : @offer = Offer.new()
    @levels = find_levels(level_choice)
    respond_to do |format|
      format.js {}
      format.json {render :json => {:levels => @levels}}
    end
  end

  def choice_group
    group = TopicGroup.find(params[:group_id])
    @topics = Topic.where(:topic_group_id => group.id) - current_user.offers_except_other.map(&:topic)
    respond_to do |format|
      format.js {}
      format.json {render :json => {:topics => @topics}}
    end
  end

  def get_all_offers
    render json: User.where(:id => params[:user_id]).first.offers.as_json(:include => {:topic => {:include => :topic_group}, :offer_prices => {:include => :level}}).to_json
  end


  private
  def offer_params
    params.require(:offer).permit(:description, :topic_id, :topic_group_id, :other_name, offer_prices_attributes: [:id, :level_id, :price, :_destroy]).merge(user_id: current_user.id)
  end

  def offer_price_params
    params.permit(:offer).merge(offer: @offer)
  end

  def find_user
    @user = current_user
  end
  
  def find_levels(level_code)
    return Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '')
      .where(:code => level_code).group(I18n.locale[0..3]).order(:id)
  end
  
end
