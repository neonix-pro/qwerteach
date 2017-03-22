MangoPay.configure do |c|
  c.preproduction = true
  c.client_id = ENV['MANGOPAY_CLIENT_ID'] || 'qwerteachrails'
  c.client_passphrase = ENV['MANGOPAY_PASSPHRASE'] || 'xk4YJLZvyKsyAbh7D7FTMROvrFzk421fsDOiDxHPrO6SUc0oRp'
  c.log_file = Rails.root.join('log/mangopay.log')
end