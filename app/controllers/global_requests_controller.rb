class GlobalRequestsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_global_request, only: [:show, :edit, :update, :destroy]
  before_action :find_topics, only: [:new, :create, :update, :edit]
  before_action :update_phone, only: :create

  # GET /global_requests
  # GET /global_requests.json
  def index
    if current_user.is_a?(Teacher)
      @offers = current_user.offers
      @topics = @offers.map{|o| o.topic}
      @global_requests = []
      @offers.each do |o|
        @global_requests += GlobalRequest.where(status: 0, topic: o.topic, level: o.levels.map{|l| l.id})
      end
    end
    @my_global_requests = GlobalRequest.where(user_id: current_user.id)
  end

  # GET /global_requests/1
  # GET /global_requests/1.json
  def show
  end

  # GET /global_requests/new
  def new
    @global_request = GlobalRequest.new
    @levels = []
  end

  # GET /global_requests/1/edit
  def edit
    @levels = Level.where(code: @global_request.topic.topic_group.level_code).group(:fr)
  end

  # POST /global_requests
  # POST /global_requests.json
  def create
    @global_request = GlobalRequest.new(global_request_params)
    respond_to do |format|
      if @global_request.save
        GlobalRequestNotificationsJob.perform_async(:notify_teachers_about_global_request, @global_request.id)
        format.html {
          if params[:redirect]
            redirect_to params[:redirect], notice: "Merci beaucoup pour ces informations! Nous vous mettons en relation avec les professeurs de #{@global_request.topic.title}. Gardez bien votre messagerie Qwerteach à l'oeil dans les prochaines heures."
          else
            redirect_to @global_request, notice: 'Votre demande a bien été enregistrée. Consultez votre messagerie pour voir si un professeur vous a répondu!'
          end
        }
        format.json { render :show, status: :created, location: @global_request }
      else
        format.html { render :new }
        format.json { render json: @global_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /global_requests/1
  # PATCH/PUT /global_requests/1.json
  def update
    respond_to do |format|
      if @global_request.update(global_request_params)
        format.html { redirect_to @global_request, notice: 'Votre demande a bien été modifiée' }
        format.json { render :show, status: :ok, location: @global_request }
      else
        format.html { render :edit }
        format.json { render json: @global_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /global_requests/1
  # DELETE /global_requests/1.json
  def destroy
    respond_to do |format|
      if @global_request.update(status: 1)
        format.html { redirect_to @global_request, notice: 'Votre demande a bien été supprimée' }
        format.json { render :show, status: :ok, location: @global_request }
      else
        format.html { render :edit }
        format.json { render json: @global_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def levels_by_topic
    @topic = Topic.find(params[:id])
    @levels = Level.where(code: @topic.topic_group.level_code).group(:fr)
    respond_to do |format|
      format.json {render json: @levels.to_json}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_global_request
      @global_request = GlobalRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def global_request_params
      params.require(:global_request).permit(:topic_id, :level_id, :description, :status, :price_max).merge(user_id: current_user.id, expiry_date: Time.now + 3.days)
    end

  def find_topics
    @topics = Topic.where.not(title: 'Autre')
  end

  def update_phone
    current_user.update(phone_country_code: params[:user_phone_country_code], phone_number: params[:user_phone_number])
  end
end