module Admin
  class CommentsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Comment.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Comment.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def resource_params
      params.require(:comment).permit(:title, :comment, :commentable_id).merge(user_id: current_user.id, role: 'admin', commentable_type: 'User')
    end

    def create
      resource = resource_class.new(resource_params)

      if resource.save
        redirect_to(
            [namespace, resource.commentable],
            notice: translate_with_resource("create.success"),
        )
      else
        render :new, locals: {
            page: Administrate::Page::Form.new(dashboard, resource),
        }
      end
    end
  end
end
