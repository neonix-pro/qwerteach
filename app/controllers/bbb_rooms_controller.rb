class BbbRoomsController < Bigbluebutton::RoomsController
  include ActionView::Helpers::UrlHelper
  before_filter :authenticate_user!, except: [:demo_room, :join_demo]
  after_action :register_meeting_participation, only:[:join_demo, :join]
  before_filter :join_check_redirect_to_mobile, :only => [:join, :join_demo]

  def join
    super
  end

  def demo_room
    @room = BigbluebuttonRoom.find_by(name: 'Demo')
    if @room.nil?
      @room = BigbluebuttonRoom.new(demo_room_params)
      @room.save!
    end
    params[:id] = @room.id

    respond_with @room do |format|
      format.html {
        redirect_to_using_params join_demo_path(@room)
      }
    end
  end

  def join_demo
    if current_user
      @user_name = current_user.name
    else
      @user_name = 'Invité'
    end
    @user_role =  :moderator
    join_internal(@user_name, @user_role, @user_id)
  end

  def join_internal(username, role, id)
    begin
      # first check if we have to create the room and if the user can do it
      unless @room.fetch_is_running?
        if bigbluebutton_can_create?(@room, role)
          user_opts = bigbluebutton_create_options(@room)
          if @room.create_meeting(bigbluebutton_user, request, user_opts)
            logger.info "Meeting created: id: #{@room.meetingid}, name: #{@room.name}, created_by: #{bigbluebutton_user.username}, time: #{Time.now.iso8601}"
          end
        else
          flash[:error] = t('bigbluebutton_rails.rooms.errors.join.cannot_create')
          redirect_to_on_join_error
          return
        end
      end

      # gets the token with the configurations for this user/room
      token = @room.fetch_new_token
      options = if token.nil? then {} else { :configToken => token } end

      # set the create time and the user id, if they exist
      options.merge!({ createTime: @room.create_time }) unless @room.create_time.blank?
      options.merge!({ userID: id }) unless id.blank?

      # room created and running, try to join it
      url = @room.join_url(username, role, nil, options)
      unless url.nil?
        # change the protocol to join with a mobile device
        if BigbluebuttonRails.use_mobile_client?(browser) &&
            #!BigbluebuttonRails.value_to_boolean(params[:desktop])
            !ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:desktop])
          url.gsub!(/^[^:]*:\/\//i, "bigbluebutton://")
        end

        redirect_to url
      else
        flash[:error] = t('bigbluebutton_rails.rooms.errors.join.not_running')
        redirect_to_on_join_error
      end

    rescue BigBlueButton::BigBlueButtonException => e
      flash[:error] = e.to_s[0..200]
      redirect_to_on_join_error
    end
  end

  def join_check_redirect_to_mobile
    return if !BigbluebuttonRails.use_mobile_client?(browser) ||
        ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:auto_join]) ||
        ActiveRecord::Type::Boolean.new.type_cast_from_database(params[:desktop])

    # since we're redirecting to an intermediary page, we set in the params the params
    # we received, including the referer, so we can go back to the previous page if needed
    filtered_params = select_params_for_join_mobile(params.clone)
    begin
      filtered_params[:redir_url] = Addressable::URI.parse(request.env["HTTP_REFERER"]).path
    rescue
    end

    redirect_to join_mobile_bigbluebutton_room_path(@room, filtered_params)
  end

  def room_invite
    @interviewee = User.find(params[:user_id])
    bigbluebutton_room = {
        :lesson_id => 0,
        :owner_type => 'Admin',
        :owner_id => current_user.id.to_s,
        :server_id => 1,
        :name => "Interview "+@interviewee.id.to_s+'_'+current_timestamp.to_s,
        :param => @interviewee.id.to_s+'_'+current_timestamp.to_s,
        :record_meeting => 1,
        :logout_url => ENV['MAILER_HOST']+':3000', #TODO: make dynamic
        :duration => 0,
        :auto_start_recording => 1,
        :allow_start_stop_recording => 0,
        :autoJoin => 0
    }
    params.merge!(:bigbluebutton_room => bigbluebutton_room)
    create
  end

  # redefinie pour changer le redirect et faire entrer l'utilisateur directement dans la classe
  def create
    @room = BigbluebuttonRoom.new(room_params)

    if params[:bigbluebutton_room] and
        (not params[:bigbluebutton_room].has_key?(:meetingid) or
            params[:bigbluebutton_room][:meetingid].blank?)
      @room.meetingid = @room.name
    end

    respond_with @room do |format|
      if @room.save
        message = t('bigbluebutton_rails.rooms.notice.create.success')
        subject = current_user.firstname + " vous invite dans une classe virtuelle. "
        subject += link_to('Cliquez ici', join_bigbluebutton_room_path(@room), target: '_blank') + " pour la rejoindre."
        body = "" + join_bigbluebutton_room_path(@room).to_s
        @interviewee.send_notification(subject, body, current_user, nil, 200) unless @interviewee.nil?
        format.html {
          redirect_to_using_params join_bigbluebutton_room_path(@room)
        }
        format.json {
          render :json => {:message => message}, :status => :created
        }
      else
        format.html {
          message = t('bigbluebutton_rails.rooms.notice.create.failure')
          unless @interviewee.nil?
            redirect_to user_path(@interviewee), :notice => message
          else
            redirect_to admin_users_path, :notice => @room.errors.full_messages.to_sentence
          end

        }
        format.json { render :json => @room.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def end_room
    @room = BbbRoom.where(:param => params[:room_id]).first
    @teacher = @room.lesson.teacher
  end

  def invite
    @bbbRoom = BbbRoom.find_by(param: params[:id])
    super
  end

  def masterclass_room
    bigbluebutton_room = {
        :lesson_id => 0,
        :masterclass_id => params[:id],
        :owner_type => 'Admin',
        :owner_id => current_user.id.to_s,
        :server_id => 1,
        :name => "Formation nouveaux professeurs du #{Time.now.strftime('%d %B %Y')} ##{current_timestamp.to_s}",
        :param => 'Masterclass_'+current_timestamp.to_s,
        :record_meeting => 0,
        :logout_url => ENV['MAILER_HOST']+':3000', #TODO: make dynamic
        :duration => 0,
        :auto_start_recording => 1,
        :allow_start_stop_recording => 0
    }
    params.merge!(:bigbluebutton_room => bigbluebutton_room)
    create
  end

  private
  def room_allowed_params
    [:name, :server_id, :meetingid, :attendee_key, :moderator_key, :welcome_msg,
     :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
     :owner_type, :external, :param, :record_meeting, :duration, :default_layout, :presenter_share_only,
     :auto_start_video, :auto_start_audio, :background,
     :moderator_only_message, :auto_start_recording, :allow_start_stop_recording, :lesson_id, :masterclass_id,
     :metadata_attributes => [:id, :name, :content, :_destroy, :owner_id]]
  end

  def demo_room_params
    params[:bigbluebutton_room] = {        :lesson_id => 0,
                                           :owner_type => 'Admin',
                                           :owner_id => 26,
                                           :server_id => 1,
                                           :name => "Demo",
                                           :param => "Demo",
                                           :record_meeting => 0,
                                           :logout_url => ENV['MAILER_HOST']+':3000',
                                           :duration => 0,
                                           :auto_start_recording => 0,
                                           :allow_start_stop_recording => 0
    }
  end

  def register_meeting_participation
    if current_user
      meeting = BbbMeeting.find_by(meetingid: @room.meetingid)
      meeting.users << current_user
      meeting.save!
    end
  end

  def bigbluebutton_user
    current_user.nil? ? User.new(firstname: 'Invité') : current_user
  end

end