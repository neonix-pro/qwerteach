#UPDATE users SET avatar_file_name = REPLACE (avatar_file_name, '/photo', '') WHERE avatar_file_name LIKE '%/photo%'


User.where.not(avatar_file_name: '').each do |user|
  if File.file?("#{Rails.root}/public/system/avatars/QWPICS#{user.avatar_file_name}")
    File.open("#{Rails.root}/public/system/avatars/QWPICS#{user.avatar_file_name}") do |f|
      user.avatar = f
      user.skip_confirmation_notification!
      user.save
      puts "#{Rails.root}/public/system/avatars/QWPICS#{user.avatar_file_name}"
      puts "OK"
    end
  end
  puts "#{Rails.root}/public/system/avatars/QWPICS#{user.avatar_file_name}"
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


User.where('avatar_file_name LIKE "%s://%"').order(id: :desc).each do |user|
  img_url = user.avatar_file_name
  res = Net::HTTP.get_response(URI.parse(img_url))
  unless res.code.to_i >= 200 && res.code.to_i < 400
    File.open("#{Rails.root}/public/system/defaults/small/missing.png") do |f|
      user.avatar = f
      user.skip_confirmation_notification!
      user.save
    end
  end
end

User.where('avatar_file_name LIKE "%s://%"').order(id: :desc).each do |user|
  img_url = user.avatar_file_name
  res = Net::HTTP.get_response(URI.parse(img_url))
  if res.code.to_i >= 200 && res.code.to_i < 400
    user.avatar = URI.parse("#{user.avatar_file_name}")
    user.skip_confirmation_notification!
    user.save
  end
end

User.where(avatar_file_name: '').each do |user|
  File.open("#{Rails.root}/public/system/defaults/small/missing.png") do |f|
    user.avatar = f
    user.skip_confirmation_notification!
    user.save
  end
end

User.where("description LIKE '%\\\\r%'").each do |u|
  u.description = u.description.gsub('\\r\\n', '<br />')
  u.skip_confirmation_notification!
  u.save
end

User.where.not(id: 26, mango_id: nil).each do |u|
  params = {description: "wallet transfert #{u.id}", tag: MangoUser::WALLET_TRANSFERT_TAG}
  MangoPay::Wallet.create({
                              :owners => [u.mango_id],
                              :currency => "EUR"
                          }.merge(params).camelize_keys)
  MangoPay::Wallet.update(u.wallets.second.id, {tag: 'Bonus'})

end
for i in 101..110
  User.where.not(id: 26, mango_id: nil).limit(10).offset(10*i).each do |u|
    if u.wallets.count <3
      puts u.wallets.count
    end
  end
end

for i in 101..110
  User.where.not(id: 26, mango_id: nil).limit(10).offset(10*i).each do |u|
    if u.wallets.count < 3
      params = {description: "wallet transfert #{u.id}", tag: MangoUser::WALLET_TRANSFERT_TAG}
      MangoPay::Wallet.create({
                                  :owners => [u.mango_id],
                                  :currency => "EUR"
                              }.merge(params).camelize_keys)
      MangoPay::Wallet.update(u.wallets.second.id, {tag: 'Bonus'})
      puts u.wallets.count
    end
  end
end