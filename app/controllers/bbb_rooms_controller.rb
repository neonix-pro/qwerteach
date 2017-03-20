require 'pp'
class BbbRoomsController < Bigbluebutton::RoomsController
  before_filter :authenticate_user!, except: [:demo_room, :join_demo]

  def join
    super
    # logging that the user joined a room
    meeting = BbbMeeting.find_by(meetingid: @room.meetingid)
    meeting.users << current_user
    meeting.save
  end


  def demo_room
    @room = BigbluebuttonRoom.find_by(name: 'Demo')
    if @room.id.nil?
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
    @user_name = 'Invité'
    join_internal(@user_name, @user_role, @user_id)
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
    @room ||= BigbluebuttonRoom.new(room_params)

    if params[:bigbluebutton_room] and
        (not params[:bigbluebutton_room].has_key?(:meetingid) or
            params[:bigbluebutton_room][:meetingid].blank?)
      @room.meetingid = @room.name
    end

    respond_with @room do |format|
      if @room.save
        message = t('bigbluebutton_rails.rooms.notice.create.success')
        subject = current_user.firstname + " vous invite dans une classe."
        body = "" + join_bigbluebutton_room_path(@room).to_s
        @interviewee.send_notification(subject, body, current_user)
        format.html {
          redirect_to_using_params join_bigbluebutton_room_path(@room)
        }
        format.json {
          render :json => {:message => message}, :status => :created
        }
      else
        format.html {
          message = t('bigbluebutton_rails.rooms.notice.create.failure')
          redirect_to user_path(@interviewee), :notice => message
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

  private
  def room_allowed_params
    [:name, :server_id, :meetingid, :attendee_key, :moderator_key, :welcome_msg,
     :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
     :owner_type, :external, :param, :record_meeting, :duration, :default_layout, :presenter_share_only,
     :auto_start_video, :auto_start_audio, :background,
     :moderator_only_message, :auto_start_recording, :allow_start_stop_recording, :lesson_id,
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

end