class PagesController < ApplicationController
	def show
		render template: "pages/#{params[:page]}"
    
    # recipients = User.where("id != ?", current_user.id)

    # recipients.each do |recipient|
    #   notification = recipient.notify('subject', 'body', nil, true, 100, false, current_user)
    #   PrivatePub.publish_to '/notifications', :notification => notification
    # end

	end
end