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
      user = User.find(params[:id])
      conversations = user.mailbox.conversations
      if conversations.between(user, current_user).blank?
        conversations = conversations.to_a.unshift(
          subject: "#{current_user.name} vous pose une question!",
          recipients: [user, current_user],
          count_messages: 0,
          messages: []
        )
      end
      @conversations = Kaminari
        .paginate_array(conversations, total_count: conversations.count)
        .page(params[:page])
        .per(5)
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
