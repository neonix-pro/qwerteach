class DegreesController < ApplicationController
  def index
    @degrees = Degree.where(:user=>current_user)
  end

  def new
    @degree = Degree.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gallery }
    end
  end

  def create
    @degree = Degree.new(degree_params)
    respond_to do |format|
      if @degree.save
        format.html { redirect_to action: "index", notice: 'Degree successfully created.' }
        format.json { render json: @degree, status: :created, location: @degree }
      else
        format.html { redirect_to @degree, notice: 'Degree not created.'}
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end

  end

  private
  def degree_params
    params.require(:degree).permit(:title, :institution, :completion_year, :type, :user_id, :level_id).merge(user_id: current_user.id)
  end

end
