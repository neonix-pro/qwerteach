class UsersController < ApplicationController
	def show
		@user = User.find(params[:id]);
	end

	def index
    @search = Sunspot.search(Advert)  do
      fulltext params[:q]
      order_by(:topic_id, "desc")
      #paginate :page => params[:page], :per_page => 5
      #paginate(:page => params[:page] || 1, :per_page => 2)
      #group :user_email do
       # limit 100
        #group_field
      #end
    end
    #@users = @search.results
  end

end
