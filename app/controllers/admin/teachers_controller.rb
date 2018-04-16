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
    helper_method :teacher

    def destroy
      # suspends the user from signing in
      if requested_resource.block
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end

    def show
      @conversations = teacher.mailbox.conversations.page(params[:page]).per(10)
      @conversation_admin = SendMessage.conversation_between(current_user, teacher)
      @conversation_admin ||= Mailboxer::Conversation.new()
      super
    end

    def nav_link_state(resource)
      case resource
        when :teachers then true
        when :postuling_teachers then action_name == 'postuling_teachers'
        when :approved_teachers then action_name == 'index'
        when :inactive_teachers then action_name == 'inactive_teachers'
        else false
      end ? :active : :inactive
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

    def postuling_teachers
      params[:order]= 'updated_at' if params[:order].nil?
      index
    end

    def inactive_teachers
      index
    end

    private

    def teacher
      requested_resource
    end

    def scoped_resource
      case action_name
      when 'index'
        Teacher.active.where(postulance_accepted: true)
      when 'postuling_teachers'
        Teacher.active.postuling
      when 'inactive_teachers'
        Teacher.unscoped.where(active: false)
      else
        super
      end
    end

  end
end
