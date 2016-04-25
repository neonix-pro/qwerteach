class BbbRoomsController < Bigbluebutton::RoomsController
  before_filter :authenticate_user!

  def join_user_params
    # gets the user information, given priority to a possible logged user
    if current_user.nil?
      @user_name = params[:user].blank? ? nil : params[:user][:name]
      @user_id = nil
    else
      @user_name = current_user.name
      @user_id = current_user.id
    end

    # the role: nil means access denied, :key means check the room
    # key, otherwise just use it
    @user_role = bigbluebutton_role(@room)
    if @user_role.nil?
      raise BigbluebuttonRails::RoomAccessDenied.new
    elsif @user_role == :key
      @user_role = @room.user_role(params[:user])
    end

    if @user_role.nil? or @user_name.blank?
      flash[:error] = t('bigbluebutton_rails.rooms.errors.join.failure')
      redirect_to_on_join_error
    end
  end

  private
  def room_allowed_params
    [ :name, :server_id, :meetingid, :attendee_key, :moderator_key, :welcome_msg,
      :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
      :owner_type, :external, :param, :record_meeting, :duration, :default_layout, :presenter_share_only,
      :auto_start_video, :auto_start_audio, :background,
      :moderator_only_message, :auto_start_recording, :allow_start_stop_recording, :lesson_id ,
      :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ] ]
  end



end