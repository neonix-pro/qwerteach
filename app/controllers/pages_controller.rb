class PagesController < ApplicationController
	def show
		render template: "pages/#{params[:page]}"
    
    # users = User.where("id != ?", current_user.id)
    # notification = Mailboxer::Notification.notify_all(users, 'subject', 'body')
    # PrivatePub.publish_to '/notifications/'+users.first.id.to_s, :notification => notification

	end
end