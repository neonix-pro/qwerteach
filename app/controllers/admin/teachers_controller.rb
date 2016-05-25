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

    def index
      search_term = params[:search].to_s.strip
      resources = Teacher.where(:postulance_accepted=>true)
      resources = resources.page(params[:page]).per(records_per_page)
      page = Administrate::Page::Collection.new(dashboard, order: order)

      render locals: {
          resources: resources,
          search_term: search_term,
          page: page,
      }
    end

    def nav_link_state(resource)
      if params[:id] && !requested_resource.postulance_accepted
        resource_name = :postuling_teacher
      else
        resource_name = :teacher
      end
      if resource_name.to_s.pluralize == resource.to_s
        :active
      else
        :inactive
      end
    end

  end
end
