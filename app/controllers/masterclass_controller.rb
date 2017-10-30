class MasterclassController < ApplicationController
  # load_and_authorize_resource
  # before_action :authenticate_user!
  #
  # def create
  #   @masterclass = Masterclass.new(masterclass_params)
  #   if @masterclass.save
  #     redirect_to masterclass_bbb_rooms_path(@masterclass.id)
  #   else
  #     redirect_to admin_users_path, danger: "impossible de créer la masterclass #{@masterclass.error_messages.to_sentence}"
  #   end
  # end
  #
  # private
  # def masterclass_params
  #   params[:masterclass] = {admin: current_user, time_start: Time.now}
  # end
end
