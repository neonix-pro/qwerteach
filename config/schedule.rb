
every 30.minutes do
  rake "bigbluebutton_rails:recordings:update"
end

every 2.minutes do
command "echo 'you can use raw cron syntax too'"
end

every 1.minutes do
  rake "message_stat"
end