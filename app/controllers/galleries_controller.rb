# Source : https://github.com/hackhowtofaq/multiple_file_upload_paperclip_rails
class GalleriesController < ApplicationController
  load_and_authorize_resource
  # GET /galleries
  # GET /galleries.json
  def index
    @galleries = Gallery.where(:user=>current_user)
    @gallery = @galleries.last
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gallery }
    end
  end

  # GET /galleries/1
  # GET /galleries/1.json
  def show
    @gallery  = Gallery.find(params[:id])
    @pictures = @gallery.pictures

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gallery }
    end
  end

  # GET /galleries/new
  # GET /galleries/new.json
  def new
    @gallery = Gallery.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gallery }
    end
  end

  # GET /galleries/1/edit
  def edit
    @gallery = Gallery.find(params[:id])
  end

  # POST /galleries
  # POST /galleries.json
  def create
    @gallery = Gallery.new(gallery_params)
    respond_to do |format|
      if @gallery.save

        if params[:images]
          # The magic is here ;)
          params[:images].each { |image|
            @gallery.pictures.create(image: image)
          }
        end

        format.html { redirect_to @gallery, notice: 'Gallery was successfully created.' }
        format.json { render json: @gallery, status: :created, location: @gallery }
      else
        format.html { redirect_to @gallery, notice: 'Gallery not created.'}
        format.json { render json: @gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /galleries/1
  # PUT /galleries/1.json
  def update
    @gallery = Gallery.find(params[:id])
    @user = User.find(@gallery.user_id)
    nb = @gallery.pictures.count
    respond_to do |format|

      if @gallery.update_attributes(gallery_params)
        if params[:images]
          # The magic is here ;)
          params[:images].each { |image|
            @gallery.pictures.create(image: image)
          /  @user.avatar = image
            @user.save/
            if ( @gallery.pictures.count == nb)
              format.html { redirect_to @gallery, notice: 'Gallery not updated.'}
              format.json { render json: @gallery.errors, status: :unprocessable_entity }
            end
            nb = @gallery.pictures.count
          }
        end
        format.html { redirect_to @gallery, notice: 'Gallery was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gallery.errors, status: :unprocessable_entity }
      end
    end
  end

  # Not used
  # DELETE /galleries/1
  # DELETE /galleries/1.json
  def destroy
    @gallery = Gallery.find(params[:id])
    @gallery.destroy

    respond_to do |format|
      format.html { redirect_to galleries_url }
      format.json { head :no_content }
    end
  end

  private
  def gallery_params
    params.permit(:pictures, :user_id).merge(user_id: current_user.id)
  end
end