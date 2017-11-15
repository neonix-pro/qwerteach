class BbbRoom < BigbluebuttonRoom

  belongs_to :lesson
  belongs_to :masterclass

  def params_interview(interviewee)
    bigbluebutton_room = {
        :lesson_id => 0,
        :owner_type => 'Admin',
        :owner_id => current_user.id.to_s,
        :server_id=>1, 
        :name=>"Interview "+interviewee.id+' '+current_timestamp.to_s, 
        :param=>interviewee.id+' '+current_timestamp.to_s, 
        :record_meeting=>1, 
        :duration=>0, 
        :auto_start_recording=>1, 
        :allow_start_stop_recording=>0
    }
  end

  def create_room_options
    false
  end

end