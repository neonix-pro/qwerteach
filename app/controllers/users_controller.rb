class UsersController < ApplicationController

  before_filter :authenticate_user!, only: [:update]
  before_action :filter_param, only: :index

  def show
    @user = User.find(params[:id])
    @me = current_user
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @offers = @user.offers.order(:topic_group_id)
      @offers_single = @offers.group_by(&:topic_group_id).map{|topic_group, offers| offers.first if offers.count == 1}.compact
      @prices = @offers.map{ |d| d.offer_prices.map{ |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size unless @notes.empty?
      @profSimis = @user.similar_teachers(4)
    end
    if @me
      @conversation = Conversation.participant(@me).where('mailboxer_conversations.id in (?)', Conversation.participant(@user).collect(&:id))
    end
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    search_sorting_options
    @sunspot_search = Sunspot.search(Offer) do
      with(:postulance_accepted, true)
      with(:active, true)
      fulltext search_text unless params[:topic].nil? || params[:topic].empty?
      order_by :online, :desc
      order_by(sorting, sorting_direction(params[:search_sorting]))
      group :user_id_str
      with(:first_lesson_free, true) if params[:filter] == 'first_lesson_free'
      with(:online, true) if params[:filter] == 'online'
      with(:has_reviews).greater_than(0) if params[:filter] == 'has_reviews'
      paginate(:page => params[:page], :per_page => 12)
    end
    @search = []
    @total = @sunspot_search.group(:user_id_str).total
    @sunspot_search.group(:user_id_str).groups.each do |group|
      group.results.each do |result|
        @search.push(result.user)
      end
    end
    @pagin = Kaminari.paginate_array(@search, total_count: @total).page(params[:page]).per(12)
    #end
    if params[:location] == 'landing'
      render 'landing_page_teachers'
    end
  end

  def profs_by_topic
    redirect_to profs_by_topic_path(params[:topic], params: params)
  end

  def unapproved_teachers
    search_sorting_options
    @sunspot_search = Sunspot.search(Offer) do
      fulltext search_text unless params[:topic].nil? || params[:topic].empty?
      order_by :online, :desc
      order_by(sorting, sorting_direction(params[:search_sorting]))
      group :user_id_str
      with(:first_lesson_free, true) if params[:filter] == 'first_lesson_free'
      with(:online, true) if params[:filter] == 'online'
      with(:has_reviews).greater_than(0) if params[:filter] == 'has_reviews'
      paginate(:page => params[:page], :per_page => 12)
    end
    @search = []
    @total = @sunspot_search.group(:user_id_str).total
    @sunspot_search.group(:user_id_str).groups.each do |group|
      group.results.each do |result|
        @search.push(result.user) if result.user.is_a?(Teacher)
      end
    end
    @pagin = Kaminari.paginate_array(@search, total_count: @total).page(params[:page]).per(12)
    render 'index'
  end

  def both_users_online
    current = User.find(params[:user_current])
    other = User.find(params[:user_other])
    if current.online? && other.online?
      render :json => { :online => "true"}
    else
      render :json => { :online => "false"}
    end
  end

  def search_sorting_options
    @sorting_options = [["pertinence", "qwerteach_score"], ["prix", "min_price"], ["dernière connexion", "last_seen"]]
  end

  def sorting_direction(sort)
    case sort
      when "qwerteach_score"
        r = "desc"
      when "min_price"
        r = "asc"
      when "last_seen"
        r = "desc"
      else
        r = "desc"
    end
    r
  end

  def sorting
    if params[:search_sorting]
      @sorting_options.each do |option|
        return params[:search_sorting] if params[:search_sorting] == option[1]
      end
      "qwerteach_score"
    else
      "qwerteach_score"
    end
  end

  def search_text
    @topic = Topic.where('lower(title) = ?', params[:topic]).first
    if @topic.nil?
      @topic_group = TopicGroup.where('lower(title) = ?', params[:topic]).first
    end
    @search_topic ||= @topic || @topic_group
    unless @search_topic.nil?
      @search_text ||= @search_topic.title
    else
      @search_text ||= params[:topic]
    end
    if @search_text.nil? || @search_text.empty?
      @search_text = 'tous les profs'
    end
    @search_text
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Votre profil a bien été modifié"
      respond_to do |format|
        format.html {redirect_to edit_user_registration_path(@user)}
        format.json {render :json => {:user => @user, :success => "true", 
          :message => "Votre profil a bien été modifié."}}
      end and return
    else
      flash[:error] = "La modification a échoué"
      respond_to do |format|
        format.html {redirect_to edit_user_registration_path(@user)}
        format.json {render :json => {:user => @user, :success => "false", 
          :message => "La modification a échoué."}}
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:firstname, :lastname, :birthdate, :phone_country_code, :phone_number,
                                   :gender, :occupation, :description, :level_id,
                                   :time_zone, :avatar, :crop_x, :crop_y, :crop_h, :crop_w,
                                  :first_lesson_free, :video_url)
    end
  
    def filter_param
      @filter = params[:filter]
    end
end
