
class PagesController < ApplicationController
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
end