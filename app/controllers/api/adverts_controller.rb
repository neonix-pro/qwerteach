class Api::AdvertsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def create
    user_id = params[:advert]["id"]
    topic_group_id = params[:advert]["topic_group_id"]
    topic_id = params[:advert]["topic_id"]
    other_name = params[:advert]["other_name"]
    unless Advert.where(user_id: user_id).where(topic_id: topic_id).where(topic_group_id: topic_group_id).where(other_name: other_name).empty?
      render :json => {:success => "exists"}
      return
    else
      if params[:advert]["advert_price"]
        advert = Advert.new
        advert.user_id = user_id
        advert.topic_id = topic_id
        advert.topic_group_id = topic_group_id
        advert.other_name = other_name
        advert.description = params[:advert]["description"]
        if advert.save
          jsonArray = params[:advert]["advert_price"]
          jsonArray.each do |object|
            advert_price = AdvertPrice.new
            advert_price.advert_id = advert.id
            advert_price.level_id = object["level_id"]
            advert_price.price = object["price"]
            advert_price.save
          end
          render :json => {:success => "true"}
          return
        else
          render :json => {:success => "false"}
          return
        end
      else
        render :json => {:success => "need"}
        return
      end
    end
  end
  
  def update
    advert_id = params[:advert]["id"]
    advert = Advert.find(advert_id)
    advert.topic_group_id = params[:advert]["topic_group_id"]
    advert.topic_id = params[:advert]["topic_id"]
    advert.other_name = params[:advert]["other_name"]
    advert.description = params[:advert]["description"]
    if advert.save
      advert_price = AdvertPrice.where(advert_id: advert_id)
      advert_price.all.each do |obj|
        obj.destroy
      end
      if not advert_price.present?
        jsonArray = params[:advert]["advert_price"]
        jsonArray.each do |object|
          advert_price = AdvertPrice.new
          advert_price.advert_id = advert_id
          advert_price.level_id = object["level_id"]
          advert_price.price = object["price"]
          advert_price.save
          end
      end
      render :json => {:success => "true"}
    else
      render :json => {:success => "false"}
      return
    end
    
  end
  
  def show
    user_id = params[:user]["id"]
    advert = Advert.where(user_id: user_id)
    if advert.nil?
      render :json => {:success => "false"}
      return
    else
      topic_title = Array.new
      advert.all.each do |ad|
        topic_id = ad.topic_id
        topic = Topic.find_by(id: topic_id)
        topic_title.push topic.title
      end
      render :json => {:success => "true", :advert => advert.as_json, :topic_title => topic_title.as_json}
      return
    end
  end
  
  def delete
    advert_id = params[:advert]["id"]
    advert = Advert.find(advert_id)
    if not advert.nil?
      advert_price = AdvertPrice.where(advert_id: advert_id)
      if not advert_price.present?
        advert.destroy
        render :json => {:success => "true"}
        return
      else
        advert_price.all.each do |obj|
          obj.destroy
        end
        advert.destroy
        render :json => {:success => "true"}
        return
      end
      return
    else
      render :json => {:success => "false"}
      return
    end
  end
  
  def find_advert_prices
    advert_id = params[:advert_price]["advert_id"]
    advert_price = AdvertPrice.where(advert_id: advert_id)
    if not advert_price.nil?
      render :json => {:advert_price => advert_price.as_json}
      return
    end
  end
  
end
