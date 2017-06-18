class Api::TopicsController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def get_all_topics
    topics = Array.new
    Topic.all.each do |t|
      topics.push(t)
    end
    render :json => {:topics => topics}
  end
  
end
