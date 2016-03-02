class DegreesController < ApplicationController
  before_filter :find_degree, only: [:edit, :update, :destroy]
  def index
    @degrees = Degree.where(:teacher=>current_user)
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
        format.html { redirect_to degrees_path, notice: "Degree successfully created" }
        format.json { render json: @degree, status: :created, location: @degree }
      else
        format.html { redirect_to @degree, notice: 'Degree not created.'}
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @degree.update(degree_params)
      redirect_to degrees_path, notice: "Degree successfully modified"
    else
      render 'edit', alert: 'Oops! il y a eu un problème...'
    end
  end

  def destroy
    respond_to do |format|
      if @degree.delete
        format.html { redirect_to degrees_path, notice: 'Degree successfully deleted.' }
        format.json { render json: @degree, status: :created, location: @degree }
      else
        format.html { redirect_to @degree, notice: 'Degree not deleted.'}
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  def degree_params
    params.require(:degree).permit(:title, :institution, :completion_year, :type, :user_id, :level_id).merge(user_id: current_user.id)
  end

  def find_degree
    @degree = Degree.find(params[:id])
  end

end
