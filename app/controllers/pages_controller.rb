class PagesController < ApplicationController

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
		render template: "pages/#{params[:page]}/#{params[:version]}"
	end

end