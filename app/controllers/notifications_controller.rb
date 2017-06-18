class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.mailbox.notifications.order('created_at DESC').limit(params[:limit]).offset(params[:offset])
    respond_to do |format|
      format.html {render :layout => false}
      format.json {render :json => {:notifications => @notifications}}
    end
  end

  def show
    render :json => current_user.mailbox.notifications.unread.count
  end

end
