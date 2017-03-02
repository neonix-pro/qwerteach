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

    def new_comment
      @commentable = User.find(params[:user_id])
      @comment = @commentable.admin_comments.new({user_id: current_user.id})
      @page = Administrate::Page::Form.new(comment_dashboard, @comment)
      render 'admin/comments/new'
    end

    def suspend

    end

    private

    def comment_dashboard
      Administrate::ResourceResolver.new("admin/comments").dashboard_class.new
    end

  end
end
