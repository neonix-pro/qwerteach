module Admin
  class UsersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = User.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   User.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def show_conversation
      @conversation = Mailboxer::Conversation.find(params[:id])
      @messages = @conversation.messages.page(params[:page]).per(20).order(id: :asc)
      render 'fields/mailboxer_conversation_field/show'
    end

  end
end
