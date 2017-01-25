class Api::GroupTopicsController < ApplicationController
  def show
    topic_groups = Array.new
    
    TopicGroup.all.each do |tg|
      topic_groups.push tg
    end
    
    render :json => {:topic_groups => topic_groups}
  end
end
