module Admin
  class ConversationsController < Admin::ApplicationController
    helper_method :conversation
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Conversation.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Conversation.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    private

    def conversation
      requested_resource
    end

    def default_params
      params[:order] ||= "updated_at"
      params[:direction] ||= "desc"
    end

    def resource_includes
      [:messages]
    end
  end
end
