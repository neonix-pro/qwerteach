class Api::TopicsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  #def show 
    #topic_group = TopicGroup.find_by_id(params["id"])
    #level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group.level_code).group(I18n.locale[0..3]).order(:id)
    #render :json => {:topics => topic_group.topics, :levels => level}
    #return
  #end
  
  def get_all_topics
    topics = Array.new
    Topic.all.each do |t|
      topics.push(t)
    end
    render :json => {:topics => topics}
  end
  
end
