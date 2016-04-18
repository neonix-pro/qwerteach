class PagesController < ApplicationController
	def show
		render template: "pages/#{params[:page]}"
    
    #Création d'une notification fictive
      # recipients = User.where("id != ?", current_user.id)
      # body = current_user.firstname+' '+current_user.email+' a visité la page '+params[:page]
      # recipients.each do |recipient|
      #   notification = recipient.notify('subject', body, nil, true, 100, false, current_user)
      #   PrivatePub.publish_to '/notifications', :notification => notification
      # end

	end
end