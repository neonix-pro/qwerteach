class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.mailbox.notifications.all
    render :layout => false
  end
end
