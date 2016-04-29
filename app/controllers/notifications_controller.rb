class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.mailbox.notifications.order('created_at DESC').limit(params[:limit]).offset(params[:offset])
    render :layout => false
  end

  def show
    render :json => current_user.mailbox.notifications.unread.count
  end

end
