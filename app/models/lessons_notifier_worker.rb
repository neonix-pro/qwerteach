class LessonsNotifierWorker
  @queue = :bigbluebutton_rails

  def self.perform(*args)
    @beginning_lessons = Lesson.where(:time_start => (DateTime.now - 10.minutes)..(DateTime.now), :status => 2)
   # @beginning_lessons = Lesson.all
    Resque.enqueue(LessonsNotifierWorker)
    @beginning_lessons.each do |bl|
      # bbb_room
      @interviewee = bl.teacher
      bigbluebutton_room = {
          :lesson_id => bl.id,
          :owner_type => 'Admin',
          :owner_id => bl.teacher.id.to_s,
          :server_id => 1,
          :name => "Interview "+@interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :param => @interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :record_meeting => 1,
          :logout_url => 'http://localhost:3000/bbb_rooms/end_room/'+@interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :duration => 0,
          :auto_start_recording => 1,
          :allow_start_stop_recording => 0
      }
      @room = BigbluebuttonRoom.new(bigbluebutton_room)
      @room.meetingid = @room.name
      if @room.save
        subject = "Votre classe est disponible. Cliquez ici pour la rejoindre."
       # body = " /bigbluebutton/rooms/#{@room.param}/join"
        body = "/bigbluebutton/rooms/#{@room.param}/invite"
        # notifs
        bl.teacher.send_notification(subject, body, bl.student)
        PrivatePub.publish_to "/lessons/#{bl.teacher_id}", :lesson => bl
        bl.student.send_notification(subject, body, bl.teacher)
        PrivatePub.publish_to "/lessons/#{bl.student_id}", :lesson => bl
      end
    end
    # Toutes les 10 mins
    sleep 600
  end
end