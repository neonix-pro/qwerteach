class PagesController < ApplicationController

	def show
		render template: "pages/#{params[:page]}"
	end

	#page d'accueil
	def index
		@featured_teachers = User.where(postulance_accepted: true).limit(13).order("RANDOM()")
		@featured_reviews =  Review.where.not(:review_text => "").order("created_at DESC").uniq.limit(3)
    @featured_topics = TopicGroup.where(featured: true) + Topic.where(featured: true)
	end

end