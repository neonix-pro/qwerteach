class LessonsController < ApplicationController
  before_action :authenticate_user!

  def index
    #Cours reçu par le Prof
    @lesson = Lesson.where(:student => current_user)
    #Cours donné par le Prof
    @lesson += Lesson.where(:teacher => current_user)


    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @lesson = Lesson.find(params[:id])
  end

  def new
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  def edit
    @Lesson = Lesson.find(params[:id])
  end

  def create
    @student_id = current_user.id
    price = params[:lesson][:price]
    debut = DateTime.new(params[:lesson]['time_start(1i)'].to_i,
                         params[:lesson]['time_start(2i)'].to_i,
                         params[:lesson]['time_start(3i)'].to_i,
                         params[:lesson]['time_start(4i)'].to_i,
                         params[:lesson]['time_start(5i)'].to_i)
    fin = DateTime.new(params[:lesson]['time_end(1i)'].to_i,
                       params[:lesson]['time_end(2i)'].to_i,
                       params[:lesson]['time_end(3i)'].to_i,
                       params[:lesson]['time_end(4i)'].to_i,
                       params[:lesson]['time_end(5i)'].to_i)

    calculatedTime = (fin - debut)*24
    @teacher = User.find(params[:lesson][:teacher_id])
    advert_prices = @teacher.adverts.where(:topic_id => params[:lesson][:topic_id]).map { |a| a.advert_prices.where(:level_id => params[:lesson][:level_id]) }
    prices = advert_prices.map { |m| m.map { |k| k.price } }
    price_is_correct = false
    prices.each do |p|
      p.each do |n|
        if (n*calculatedTime) == BigDecimal.new(price, 8)
          price_is_correct = true
        end
      end
    end
    #render 'lessons/payment_select'
    @lesson = Lesson.create(lesson_params)
    if @lesson.save
      #  format.html { redirect_to root_path, notice: 'Lesson was successfully required.' }
    end
  end

  def require_lesson
    @student_id = current_user.id
    @lesson = Lesson.new
  end

  private
  def lesson_params
    params.require(:lesson).permit(:student_id, :teacher_id, :price, :level_id, :topic_id, :topic_group_id, :time_start, :time_end).merge(:student_id => current_user.id)
  end
end
