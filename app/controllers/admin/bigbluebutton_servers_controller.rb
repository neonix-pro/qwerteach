module Admin
  class BigbluebuttonServersController < Admin::ApplicationController
    # To customize the behavior of this controller,
    # simply overwrite any of the RESTful actions. For example:
    #
    # def index
    #   super
    #   @resources = Conversation.all.paginate(10, params[:page])
    # end

    # Define a custom finder by overriding the `find_resource` method:
    # def find_resource(param)
    #   Conversation.find_by!(slug: param)
    # end

    # See https://administrate-docs.herokuapp.com/customizing_controller_actions
    # for more information
    include BigbluebuttonRails::InternalControllerMethods

    respond_to :html
    respond_to :json, :only => [:index, :show, :new, :create, :update, :destroy, :activity, :rooms]
    before_filter :find_server, :except => [:index, :new, :create]

    def index
      @servers ||= BigbluebuttonServer.all
      render 'fields/bigbluebutton_server_field/index'
    end

    def show
      render 'fields/bigbluebutton_server_field/show'
    end

    def edit
      render 'fields/bigbluebutton_server_field/edit'
    end

    def new
      @server ||= BigbluebuttonServer.new
      render 'fields/bigbluebutton_server_field/new'
    end

    def create
    @server ||= BigbluebuttonServer.new(server_params)

    respond_to do |format|
      if @server.save
        format.html {
          message = t('bigbluebutton_rails.servers.notice.create.success')
          redirect_to_using_params admin_bigbluebutton_server_path(@server), :notice => message
        }
        format.json { render :json => @server, :status => :created }
      else
        format.html { redirect_to_using_params new_admin_bigbluebutton_server_path, :notice =>@server.errors.full_messages }
        format.json { render :json => @server.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

    def update
      respond_to do |format|
        if @server.update_attributes(server_params)
          format.html {
            message = t('bigbluebutton_rails.servers.notice.update.success')
            redirect_to_using_params admin_bigbluebutton_server_path(@server), :notice => message
          }
          format.json { render :json => true, :status => :ok }
        else
          format.html { redirect_to_using_params edit_admin_bigbluebutton_server(@server), :notice => @server.errors.full_messages }
          format.json { render :json => @server.errors.full_messages, :status => :unprocessable_entity }
        end
      end
    end

    def destroy
       @server.destroy

      respond_to do |format|
        format.html { redirect_to_using_params admin_bigbluebutton_servers_path }
        format.json { render :json => true, :status => :ok }
      end
    end

    protected
    def find_server
      @server ||= BigbluebuttonServer.find_by_param(params[:id])
    end

    def server_params
      unless params[:bigbluebutton_server].nil?
        params[:bigbluebutton_server].permit(*server_allowed_params)
      else
        {}
      end
    end

    def server_allowed_params
      [ :name, :url, :salt, :param ]
    end
  end
end
