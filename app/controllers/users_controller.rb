class UsersController < ApplicationController
	def show
		@user = User.find(params[:id]);
	end

	def index
    @search = Advert.search()  do
      fulltext params[:q]
      order_by(:topic_id, "desc")
      #group :user_email do
       # limit 100
        #group_field
      #end

    end
    #@users = @search.results
  end

end
