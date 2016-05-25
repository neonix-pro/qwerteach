module Admin
  class PostulingTeachersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Picture.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Picture.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def index
      search_term = params[:search].to_s.strip
      resources = Teacher.where(:postulance_accepted=>false)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render 'admin/postuling_teachers/index', locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

  end
end
