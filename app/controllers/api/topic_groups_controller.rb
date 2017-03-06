class Api::TopicGroupsController < ApplicationController
  
  def get_all_topic_groups
    topic_groups = Array.new  
    TopicGroup.all.each do |tg|
      topic_groups.push tg
    end
    render :json => {:topic_groups => topic_groups}
  end
  
end
