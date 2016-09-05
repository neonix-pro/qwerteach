require 'vcr'
#require 'webmock/rspec'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr_fixtures'
  config.configure_rspec_metadata!
  #config.ignore_hosts '127.0.0.1', 'local', 'localhost'
  config.debug_logger = File.open('log/vcr.log', 'w')
  #config.default_cassette_options = { :serialize_with => :xsyck }
  #config.locale = :ru
  config.allow_http_connections_when_no_cassette = true
end