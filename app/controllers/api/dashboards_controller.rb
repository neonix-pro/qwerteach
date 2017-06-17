class Api::DashboardsController < DashboardsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    
    unless @user.mango_id.nil?
      total_wallet = @user.total_wallets_in_cents/100
    end
    
    if @user.is_a?(Teacher)
       past_lessons_given = @user.lessons_given.past.created
    end
    
    render :json => {:upcoming_lessons => @upcoming_lessons, 
      :to_do_list =>  @pending_lessons, 
      :past_lessons => @past_lessons,
      :past_lessons_given => past_lessons_given,
      :to_unlock_lessons => @to_unlock_lessons,
      :to_review_lessons =>  @to_review_lessons,
      :total_wallet => total_wallet} 
  end
  
end
