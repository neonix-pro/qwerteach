module Admin
  class TeachersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Teacher.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Teacher.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def destroy
      # suspends the user from signing in
      if requested_resource.block
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end


    def index
      search_term = params[:search].to_s.strip
      resources = Teacher.where(postulance_accepted: true, active: true)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

    def show
      @user = User.find(params[:id])
      @conversations = @user.mailbox.conversations.page(params[:page]).per(10)
      @admins = User.where(admin: true)
      conv_check_1 = Conversation.participant(@user)
      conv_check_2 = Conversation.participant(current_user)
      @conversation_admin = (conv_check_1 & conv_check_2).first
      if @conversation_admin.nil?
        @conversation_admin = Mailboxer::Conversation.new()
      end
      @messages_admin = @conversation_admin.messages.order(id: :desc)
      @conversation = Conversation.participant(current_user).where('mailboxer_conversations.id in (?)', Conversation.participant(@user).collect(&:id))
      super
    end

    def nav_link_state(resource)
      case params[:action]
        when 'inactive_teachers'
          resource_name = :inactive_teacher
        when 'banned_users'
          resource_name = :banned_user
        when 'index'
          if params[:controller] == 'admin/teachers'
            resource_name = :teacher
          end
          if params[:controller] == 'admin/postulling_teachers'
            resource_name = :postulling_teacher
          end
      end

      if resource_name.to_s.pluralize == resource.to_s
        :active
      else
        :inactive
      end
    end

    def deactivate
      # marks the teacher as inactive
      r = Teacher.find(params[:teacher_id])
      if r.mark_as_inactive
        flash[:notice] = translate_with_resource("deactivated.success")
        redirect_to request.referer
      end
    end

    def reactivate
      # marks the teacher as active
      r = Teacher.find(params[:teacher_id])
      if r.mark_as_active
        flash[:notice] = translate_with_resource("reactivated.success")
        redirect_to request.referer
      end
    end

    def inactive_teachers
      search_term = params[:search].to_s.strip
      resources = Teacher.unscoped.where(:active=>false)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render :index, locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

  end
end
