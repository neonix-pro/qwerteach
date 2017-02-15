class OffersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user

  load_and_authorize_resource

  def index
    @offers = Offer.where(:user => current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @offers }
    end
  end

  def show
    @offer = Offer.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @offer }
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
    unless @user.is_a?(Teacher)
      @user.upgrade
    end
    if current_user.offers_except_other.map(&:topic_id).include?(params[:offer][:topic_id].to_i)
      respond_to do |format|
        flash[:notice]='Une annonce pour cette catégorie existe déjà.'
        format.html {redirect_to offers_path}
        format.json {}
        format.js {}
        return
      end
    end

    @offer = Offer.new(offer_params)
    respond_to do |format|
      if @offer.save
        format.html { redirect_to offers_path, notice: 'Votre annonce a bien été enregistrée.' }
        format.json { head :no_content }
        format.js {
          render partial: "#{params[:origin]}/create_offer", locals: {offer: @offer} if params[:origin]
        }
      else
        format.html { redirect_to @offer, danger: 'Il y a eu un problème, votre annonce, n\'a pas été mise à jour' }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
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

        format.html { redirect_to offers_path}
        format.json { head :no_content }
        format.js {}
      else
        format.html { render action: "edit" }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @offer = Offer.find(params[:id])
    Offer.destroy(@offer.id)

    respond_to do |format|
      format.html { redirect_to params[:origin].nil? ? offers_url : "/#{params[:origin]}/offers"}
      format.json {}
      format.js {}
    end
  end

  def choice
    topic = Topic.find(params[:topic_id])
    level_choice = topic.topic_group.level_code
    params.has_key?(:id) ? @offer = Offer.find_by(user_id: current_user.id, topic_id: topic.id) : @offer = Offer.new()
    @levels = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => level_choice).group(I18n.locale[0..3]).order(:id)
    respond_to do |format|
      format.js {}
    end
  end

  def choice_group
    group = TopicGroup.find(params[:group_id])
    @topics = Topic.where(:topic_group_id => group.id) - current_user.offers_except_other.map(&:topic)
    respond_to do |format|
      format.js {}
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
end
