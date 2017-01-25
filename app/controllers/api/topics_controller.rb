class Api::TopicsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def show 
    topic_group = TopicGroup.find_by_id(params["id"])
    level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group.level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:topics => topic_group.topics, :levels => level}
    return
  end
  
  def find_levels
    topic = Topic.find_by(id: params[:topic]["topic_id"])
    topic_group = TopicGroup.find_by(id: topic.topic_group_id)
    topic_group_level_code = topic_group.level_code
    levels = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:levels => levels, :topic_group_title => topic_group.title}
  end
  
  def get_all_topics
    topics = Array.new
    Topic.all.each do |tg|
      topics.push tg
    end
    render :json => {:topics => topics.as_json}
  end
  
end
