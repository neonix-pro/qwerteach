class UsersController < ApplicationController

  before_filter :authenticate_user!
  
  def show
    @user = User.find(params[:id])
    if @user.is_a?(Teacher)
      @degrees = @user.degrees
      @adverts = @user.adverts
      @prices = @adverts.map{ |d| d.advert_prices.map{ |l| l.price } }
      @reviews = @user.reviews_received
      @notes = @reviews.map { |r| r.note }
      @avg = @notes.inject { |sum, el| sum + el }.to_f / @notes.size
    end
    a = Advert.where(user_id: @user.id) #Get Advert from User
    ids = a.map{|ad| ad.topic_id }  #Get Topic from User
    adverts = Advert.where(topic_id: ids) #Check advert where Topic = Topic
    ids_user = adverts.map{|adv| adv.user_id} #Get User.id from advert
    
    idsProfSimi = []
    ids_user.each do |id| 
      if ids_user.include?(id) == true
        idsProfSimi.push(id) #Si un prof apparait 2 fois alors Push dans le tableau 
      end
    end
    
    users = User.where(postulance_accepted: true) #Get prof postulance True
    users_id = [] #Contiendra All teacher id
    new_id = [] #Contiendra les users_id sélectionné
    users_id = users.map{|u| u.id} #Get id des profs 
    
    if users_id.include?(@user.id) #Check si le user n'est pas déjà dans le tab
      users_id.delete(@user.id) #Delete
    end
    
    users_id.each do |u|
      if idsProfSimi.include?(u) 
        new_id.push(u) #Si un idTeacher apparait push dans un tab
      end
    end
    @new_ids = new_id.sample(4) #Sélection random de 4 teachers
    @profSimis = @new_ids.map{|id| User.find(id)} #Boum information user sélectionner 
  end

  # utilisation de sunspot pour les recherches, Kaminari pour la pagination
  def index
    @search = Sunspot.search(Advert) do
      fulltext params[:q]
      order_by(:topic_id, "desc")
      with(:user_age).greater_than_or_equal_to(params[:age_min]) unless params[:age_min].blank?
      with(:user_age).less_than_or_equal_to(params[:age_max]) unless params[:age_max].blank?
      with(:advert_prices_truc).greater_than(params[:min_price]) unless params[:min_price].blank?
      with(:advert_prices_truc).less_than(params[:max_price]) unless params[:max_price].blank?
    end
    @h = Hash.new()
    @search.results.each do |x|
      if @h.assoc(x.user_id).nil?
        @h.store(x.user_id, Array.new)
      end
      @h[x.user_id].push(x)
    end
    if params[:degree_id].blank?
      @pagin = User.where(:id => @h.keys, :postulance_accepted => true).order(:level_id).page(params[:page]).per(15)
    else
      @pagin = User.where(:id => @h.keys, :postulance_accepted => true).where('level_id >= ?', params[:degree_id]).order(:level_id).page(params[:page]).per(15)
    end
  end

  def both_users_online
    current = User.find(params[:user_current])
    other = User.find(params[:user_other])
    if current.last_seen > 10.minutes.ago && other.last_seen > 10.minutes.ago
      render :json => { :online => "true"}
    else
      render :json => { :online => "false"}
    end
  end

end
