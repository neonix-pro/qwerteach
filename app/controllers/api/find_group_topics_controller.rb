class Api::FindGroupTopicsController < ApplicationController
  def show
    topic_group = Array.new
    
    TopicGroup.all.each do |tg|
      topic_group.push tg
    end
    
    render :json => {:topic_group => topic_group.as_json}
  end
end
