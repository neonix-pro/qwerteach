class Api::DashboardsController < DashboardsController
  
  skip_before_filter :verify_authenticity_token
  respond_to :json
  
  def index
    super
    
    review_asked = Array.new
    to_do_list = Array.new
    
    @to_do_list.each do |lesson|
      if lesson.review_needed?(@user) && !review_asked.include?(lesson.teacher.id)
        user = User.new
        user.id = lesson.teacher.id
        user.firstname = lesson.teacher.firstname
        review_asked.push(user)
      end
      unless (lesson.paid? || lesson.upcoming?)
        if lesson.prepaid?
          to_do_list.push(lesson)
        end
      end
      if lesson.pending?(@user)
        to_do_list.push(lesson)
      end
    end
    
    #avatar = []
    #@upcoming_lessons.each do |lesson|
      #image_tag = lesson.other(current_user).avatar(:medium)
      #avatar.push(image_tag)
    #end
    
    render :json => {:upcoming_lessons => @upcoming_lessons,
      :review_asked => review_asked, :to_do_list => to_do_list}
      #:avatar => avatar}
  end
  
end
