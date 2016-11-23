class Api::FindTopicsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
  end
  
  def show
      topic_group_title = params[:topic]["title"]
      topic_group = TopicGroup.find_by(title: topic_group_title)
      topics = topic_group.topics
      topic_group_level_code = topic_group.level_code
      level = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
      render :json => {:topics => topics.as_json, :levels => level}
      return
  end
  
  def find_levels
    topic = Topic.find_by(id: params[:topic]["topic_id"])
    topic_group = TopicGroup.find_by(id: topic.topic_group_id)
    topic_group_level_code = topic_group.level_code
    levels = Level.select('distinct(' + I18n.locale[0..3] + '), id,' + I18n.locale[0..3] + '').where(:code => topic_group_level_code).group(I18n.locale[0..3]).order(:id)
    render :json => {:levels => levels.as_json, :topic_group_title => topic_group.title}
  end
  
end
