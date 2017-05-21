# All Administrate controllers inherit from this `Admin::ApplicationController`,
# making it the ideal place to put authentication logic or other
# before_filters.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    before_filter :authenticate_admin
    before_filter :default_params

    def default_params
      params[:order] ||= "id"
      params[:direction] ||= "desc"
    end

    def authenticate_admin
      logger.debug('-----'*20)
      logger.debug( session[:_csrf_token])
      logger.debug('-----'*20)
      if (current_user.blank?)
        redirect_to '/', alert: 'Not authorized.'
      else
        if (!current_user.admin?)
          redirect_to '/', alert: 'Not authorized.'
        end
      end
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end
  end
end
