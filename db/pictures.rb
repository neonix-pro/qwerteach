#UPDATE users SET avatar_file_name = REPLACE (avatar_file_name, '/photo', '') WHERE avatar_file_name LIKE '%/photo%'


User.where('id>26 AND avatar_file_name != ""').each do |user|
  if File.file?("#{Rails.root}/public/system/avatars/QWPICS/#{user.avatar_file_name}")
    File.open("#{Rails.root}/public/system/avatars/QWPICS/#{user.avatar_file_name}") do |f|
      user.avatar = f
      user.skip_confirmation_notification!
      user.save
      puts "#{Rails.root}/public/system/avatars/QWPICS/#{user.avatar_file_name}"
    end
  end
  puts "#{Rails.root}/public/system/avatars/QWPICS/#{user.avatar_file_name}"
  require "open-uri"

  if user.avatar_file_name.start_with?('http')
    begin
      user.avatar = URI.parse("http#{user.avatar_file_name}")
      user.skip_confirmation_notification!
      user.save
    rescue =>e
    end
  end
end

User.where('avatar_file_name LIKE "%s://%"').order(id: :desc).limit(10).each do |user|
  begin
    url = URI.parse("#{user.avatar_file_name}")
    user.avatar = url
    user.skip_confirmation_notification!
    user.save
  rescue =>e
    puts e.inspect
  end
end

User.where(avatar_file_name: '').each do |user|
  File.open("#{Rails.root}/public/system/defaults/small/missing.png") do |f|
    user.avatar = f
    user.skip_confirmation_notification!
    user.save
  end
end