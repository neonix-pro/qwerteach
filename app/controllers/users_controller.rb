class UsersController < ApplicationController
	def show
		@user = User.find(params[:id])
		@degrees = Degree.where(:teacher=>@user.id)
	end
end
