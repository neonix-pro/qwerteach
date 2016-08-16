require 'vcr'
#require 'webmock/rspec'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr_fixtures'
  config.configure_rspec_metadata!
  #config.ignore_hosts '127.0.0.1', 'local', 'localhost', '172.17.100.4', 'xn--e1aybc.xn--90abkldor4ah.xn--p1ai'
  config.debug_logger = File.open('log/vcr.log', 'w')
  #config.default_cassette_options = { :serialize_with => :xsyck }
  #config.locale = :ru
  #config.preserve_exact_body_bytes { true }
  # config.allow_http_connections_when_no_cassette = true
  # config.default_cassette_options = {
  #   re_record_interval: 1.week
  # }
end