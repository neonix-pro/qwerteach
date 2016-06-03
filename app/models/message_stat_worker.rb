class MessageStatWorker
  @queue = :message_stat
    
  def self.perform(user_id)
    user = User.find(user_id)
    last_message = user.messages.last
    message_not_read = user.mailbox.inbox({:is_read => false}).count
    #message_not_read = user.mailbox.inbox({:read => false}).count
    old_msg_count = user.messages.count
    
    msg_response_time = TimeDifference.between(Time.now, user.messages.last.created_at).in_minutes
    response_time = (user.average_response_time * old_msg_count)+msg_response_time/old_msg_count +1
    response_rate = (message_not_read / old_msg_count +1) * 100 #TauxDeReponse en % ET Stocker en Entier Db
    if response_rate > 100  #Lockage du % à 100
        response_rate = 100
    end
    user.update_attributes(:response_rate => response_rate, :response_time => response_time, :average_response_time => response_time)
 end 
end