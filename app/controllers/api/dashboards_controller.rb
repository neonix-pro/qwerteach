class Api::DashboardsController < DashboardsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    
    if @user.is_a?(Teacher)
      past_lessons = @user.lessons_given.past
    else
      past_lessons = @user.lessons_received.past
    end
    
    unless @user.mango_id.nil?
      total_wallet = @user.total_wallets_in_cents/100
    end
    
    render :json => {:upcoming_lessons => @upcoming_lessons,
      :to_do_list =>  @pending_lessons, :past_lessons => past_lessons, :total_wallet => total_wallet} 
  end
  
end
