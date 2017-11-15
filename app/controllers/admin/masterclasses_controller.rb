module Admin
  class MasterclassesController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # you can overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Masterclass.
    #     page(params[:page]).
    #     per(10)
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Masterclass.find_by!(slug: param)
    # end

    # See https://administrate-prototype.herokuapp.com/customizing_controller_actions
    # for more information

    def join
      @masterclass= Masterclass.find(params[:masterclass_id])
      if @masterclass.bbb_room.nil?
        redirect_to masterclass_bbb_rooms_path(params[:masterclass_id])
      else
        redirect_to join_bigbluebutton_room_path(@masterclass.bbb_room)
      end
    end

    def resource_params
      params.require(:masterclass).permit(dashboard.permitted_attributes.push(:admin)).merge({admin: current_user})
    end

  end
end
