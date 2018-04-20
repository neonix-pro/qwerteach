class PagesController < ApplicationController
  before_action :set_suspected_user_type

	def show
		@contact = Contact.new
		render template: "pages/#{params[:page]}"
	end

	#page d'accueil
	def index
		@featured_teachers =  User.where(postulance_accepted: true).where.not(avatar_score: nil).limit(13).order(avatar_score: :desc)
		@featured_reviews =  Review.where.not(:review_text => "").order("created_at DESC").uniq.limit(3)
    @featured_topics = TopicGroup.where(featured: true) + Topic.where(featured: true)
	end

  def faq
		#targets: students, teachers, parents
		#sections: generalites, lessons, videoconference, paiements, technical, teachers, bookings
		@target = params[:target] || 'students'
		@section = params[:section] || 'generalites'
	end

  def abtest
		index
		@featured_teachers_landing =  User.where(postulance_accepted: true).where.not(avatar_score: nil).limit(7).order(avatar_score: :desc)
		render template: "pages/#{params[:page]}/#{params[:version]}", layout: 'no-navbar'
		#render template: "pages/#{params[:page]}/winner", layout: 'no-navbar'
	end

  def marketing
		session[:source] = params[:source]
		render template: "pages/#{params[:target]}/#{params[:source]}", layout: 'no-navbar'
	end

  private
  def set_suspected_user_type
		if request.path_info.include?('parent') || request.path_info.include?('expats')
			session[:suspected_user_type] = 'Élève'
		elsif request.path_info.include?('Prof')
			session[:suspected_user_type] = 'Prof'
		end
	end

end