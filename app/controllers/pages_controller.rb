
class PagesController < ApplicationController
	autocomplete :topic, :title, :full => true
	def show
		render template: "pages/#{params[:page]}"
    
   
      # recipients = User.where("id != ?", current_user.id)
      # body = current_user.firstname+' '+current_user.email+' a visité la page '+params[:page]
      
      # recipients.each do |recipient|
      #   subject= 'Visit of page'
      #   body = 'User '+current_user.email+' visited the page "pages/#{params[:page]}"'
      #   recipient.send_notification(subject, body, current_user)
      # end

	end

	#page d'accueil
	def index
		@featured_teachers = User.where(postulance_accepted: true).limit(13).order("RANDOM()")
		@featured_reviews =  Review.where.not(:review_text => "").order("created_at DESC").uniq.limit(3)
    @featured_topics = TopicGroup.where(featured: true) + Topic.where(featured: true)
	end

end