module Admin
  class StudentsController < Admin::ApplicationController
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

    def index
      search_term = params[:search].to_s.strip
      resources = Student.where(:type=>'Student')
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

    def destroy
      # suspends the user from signing in
      if requested_resource.block
        flash[:notice] = translate_with_resource("blocked.success")
        redirect_to action: :index
      end
    end

  end
end
