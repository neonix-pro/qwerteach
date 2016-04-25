class BbbRoomsController < Bigbluebutton::RoomsController

  private
  def room_allowed_params
    [ :name, :server_id, :meetingid, :attendee_key, :moderator_key, :welcome_msg,
      :private, :logout_url, :dial_number, :voice_bridge, :max_participants, :owner_id,
      :owner_type, :external, :param, :record_meeting, :duration, :default_layout, :presenter_share_only,
      :auto_start_video, :auto_start_audio, :background,
      :moderator_only_message, :auto_start_recording, :allow_start_stop_recording,
      :metadata_attributes => [ :id, :name, :content, :_destroy, :owner_id ],
      :lesson_id ]
  end
end