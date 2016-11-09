class LessonsNotifierWorker
  @queue = :bigbluebutton_rails

  def self.perform(*args)
    @beginning_lessons = Lesson.where(:time_start => (DateTime.now)..(DateTime.now + 10.minutes), :status => 2)
   # @beginning_lessons = Lesson.all
    #Resque.enqueue(LessonsNotifierWorker)
    @beginning_lessons.each do |bl|
      # bbb_room
      @interviewee = bl.teacher
      bigbluebutton_room = {
          :lesson_id => bl.id,
          :owner_type => 'Admin',
          :owner_id => bl.teacher.id.to_s,
          :server_id => 1,
          :name => "Cours de "+bl.topic.title+" du "+bl.time_start.strftime("%d/%m/%Y"),
          :param => @interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :record_meeting => 1,
        #  :logout_url => 'https://qwer-dewiiid.c9users.io/bbb_rooms/end_room/'+@interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :logout_url => 'http://localhost:3000/bbb_rooms/end_room/'+@interviewee.id.to_s+'_'+DateTime.now.to_time.to_i.to_s,
          :duration => 0,
          :auto_start_recording => 1,
          :allow_start_stop_recording => 0
      }
      @room = BigbluebuttonRoom.new(bigbluebutton_room)
      @room.meetingid = @room.name
      if @room.save
        subject = "Votre classe est disponible. Cliquez ici pour la rejoindre."
        body = " /bigbluebutton/rooms/#{@room.param}/join"
        # body = "/bigbluebutton/rooms/#{@room.param}/invite"
        # notifs
        bl.teacher.send_notification(subject, body, bl.student)
        PrivatePub.publish_to "/notifications/#{bl.teacher_id}", :lesson => bl
        bl.student.send_notification(subject, body, bl.teacher)
        PrivatePub.publish_to "/notifications/#{bl.student_id}", :lesson => bl
      else
        Rails.logger.debug(@room.errors.full_messages.to_sentence)
      end
    end
  end
end