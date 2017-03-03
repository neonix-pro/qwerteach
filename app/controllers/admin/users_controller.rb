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

    def banned_users
      search_term = params[:search].to_s.strip
      resources = User.unscoped.where(:blocked=>true)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render :index, locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

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

    def destroy
      # suspends the user from signing in
      if requested_resource.block
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end

    def unblock
      requested_resource = User.unscoped.find(params[:user_id])
      if requested_resource.unblock
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end

    def nav_link_state(resource)
      case params[:action]
        when 'banned_users'
          resource_name = :banned_user
        when 'index'
          resource_name = :user
      end

      if resource_name.to_s.pluralize == resource.to_s
        :active
      else
        :inactive
      end
    end

    def become
      return unless current_user.is_admin?
      u = User.find(params[:user_id])
      sign_in(:user, u, { :bypass => true })
      flash[:notice]= "Connecté en tant que #{u.name} - #{u.id}"
      redirect_to root_url # or user_root_url
    end

    private

    def comment_dashboard
      Administrate::ResourceResolver.new("admin/comments").dashboard_class.new
    end

  end
end
