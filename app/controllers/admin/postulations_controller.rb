module Admin
  class PostulationsController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Postulation.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Postulation.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information

    def generate_text
      @postulation = Postulation.find(params[:postulation_id])
      @user = @postulation.teacher
      greetings = "Bonjour #{@user.name},  et bienvenue sur Qwerteach!"
      reason = "Je te contacte car tu postules pour être prof."
      if @postulation.corrections_needed
        reason += "Avant de te faire apparaitre comme prof sur le site, nous aimerions augmenter tes chances de te faire contacter par des élèves. Pour ce faire, je vais te demander de corriger les petits détails suivants:"
      end
      changes = @postulation.correction_text
      @text = [greetings, reason, changes].join("\r\n")
    end

    def permitted_attributes
      dashboard.permitted_attributes.push(:admin_id)
    end
  end
end
