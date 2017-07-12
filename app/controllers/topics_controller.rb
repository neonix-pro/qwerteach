class TopicsController < ApplicationController
  #autocomplete :topic, :title, :full => true
  def autocomplete_topic_title
    term = params[:term]
    topics = Topic.where('title LIKE ?', "%#{term}%").where.not(title: 'Autre').order(:title).all
    topics << Topic.where(title: 'Autre').last
    render :json => topics.map { |t| {:id => t.id, :label => t.title, :value => t.title, :topic_group_id => t.topic_group_id} }
  end
end