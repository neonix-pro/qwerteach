class GlobalRequestsController < ApplicationController
  before_action :set_global_request, only: [:show, :edit, :update, :destroy]
  before_action :find_topics, only: [:new, :create, :update]
  # GET /global_requests
  # GET /global_requests.json
  def index
    @global_requests = GlobalRequest.all
  end

  # GET /global_requests/1
  # GET /global_requests/1.json
  def show
  end

  # GET /global_requests/new
  def new
    @global_request = GlobalRequest.new
  end

  # GET /global_requests/1/edit
  def edit
  end

  # POST /global_requests
  # POST /global_requests.json
  def create
    @global_request = GlobalRequest.new(global_request_params)

    respond_to do |format|
      if @global_request.save
        format.html { redirect_to @global_request, notice: 'Global request was successfully created.' }
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
        format.html { redirect_to @global_request, notice: 'Global request was successfully updated.' }
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
    @global_request.destroy
    respond_to do |format|
      format.html { redirect_to global_requests_url, notice: 'Global request was successfully destroyed.' }
      format.json { head :no_content }
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
      params.require(:global_request).permit(:topic_id, :level_id, :description, :status).merge(:user_id => current_user.id)
    end

  def find_topics
    @topics = Topic.where.not(title: 'Autre')
  end
end
