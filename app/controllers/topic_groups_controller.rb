class TopicGroupsController < ApplicationController
  before_filter :authenticate_user!
  def choice_group
    group = TopicGroup.find(params[:group_id])
    @topics = Topic.where(:topic_group => group)
    respond_to do |format|
      format.js {}
    end
  end

end
