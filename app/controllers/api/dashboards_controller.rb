class Api::DashboardsController < DashboardsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    
    #review_asked = Array.new
    #to_do_list = Array.new
    #upcoming_lesson_avatars = Array.new
    #avg_reviews = Array.new
    
    if @user.is_a?(Teacher)
      past_lessons = @user.lessons_given.past
    else
      past_lessons = @user.lessons_received.past
    end
    
    unless @user.mango_id.nil?
      total_wallet = @user.total_wallets_in_cents/100
    end
    
    #@to_do_list.each do |lesson|
      #if lesson.review_needed?(@user) && !review_asked.include?(lesson.teacher.id)
        #user = User.new
        #user.id = lesson.teacher.id
        #user.firstname = lesson.teacher.firstname
        #review_asked.push(user)
        #avg_reviews.push(lesson.teacher.avg_reviews)
      #end
      #unless (lesson.paid? || lesson.upcoming?)
        #if lesson.prepaid?
          #to_do_list.push(lesson)
        #end
      #end
      #if lesson.pending?(@user)
        #to_do_list.push(lesson)
      #end
    #end
    
    #@upcoming_lessons.each do |lesson|
      #image_tag = lesson.other(current_user).avatar(:medium)
      #upcoming_lesson_avatars.push(image_tag)
    #end
    
    render :json => {:upcoming_lessons => @upcoming_lessons,
      #:review_asked => review_asked, 
      :to_do_list => @to_do_list, :past_lessons => past_lessons, :total_wallet => total_wallet} 
      #:avatars => upcoming_lesson_avatars, :avgs => avg_reviews}
  end
  
end
