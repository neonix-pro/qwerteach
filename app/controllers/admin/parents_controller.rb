module Admin
  class ParentsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Student.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Student.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information
    helper_method :student

    def index
      search_term = params[:search].to_s.strip
      resources = Student.where(:type=>'Parent')
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

    def show
      @conversations = student.mailbox.conversations.page(params[:page]).per(10)
      @conversation_admin = SendMessage.conversation_between(current_user, student)
      @conversation_admin ||= Mailboxer::Conversation.new()
      super
    end

    def destroy
      # suspends the user from signing in
      if requested_resource.block
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end

    private

    def student
      requested_resource
    end

  end
end
