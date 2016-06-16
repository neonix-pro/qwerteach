source 'https://rubygems.org'

#LogLinkedIn 
gem 'omniauth-linkedin-oauth2'
#TimeDiff
gem 'time_difference'
#LogFacebook
gem 'omniauth-facebook'
#LogTwitter
gem 'omniauth-twitter'
#LogGoogle
gem "omniauth-google-oauth2"
gem 'omniauth'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5.1'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
gem "haml-rails", "~> 0.9"
gem 'chosen-rails'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'devise', '3.4.1'
#bootstrap-sass is not relevant to the tutorial, but I like it for styling.
gem 'bootstrap-sass'
gem 'font-awesome-sass'

gem 'jquery-turbolinks'
# droits d'accès
gem "cancan"
gem 'minitest'
gem 'paper_trail'
# traductions
gem 'globalize', '~> 5.0.0'
gem 'rails-i18n'
# for avatars
gem "paperclip", "~> 4.3"
# for datum validations
gem 'validates_timeliness', '~> 4.0'
# crop image
gem 'jcrop-rails-v2'
# datepicker calendar
gem 'bootstrap-datepicker-rails'
#interface admin
gem "administrate", "~> 0.1.4"


# seed dump
gem 'seed_dump'

#gems for async actions
gem 'private_pub'
gem 'thin'

gem 'sunspot_solr'
gem 'sunspot_rails'

# pagination
gem 'kaminari'
#text editor
gem 'ckeditor_rails'
# wizardify models
gem 'wicked'
gem 'unread'
# mangopay!
gem 'mangopay'
gem 'countries'
gem 'progress_bar'
# conversations & messages
gem 'mailboxer'
# cron jobs
gem 'whenever', :require => false

# validate card number
gem 'jquery-form-validator-rails'


# datetimepicker
gem 'momentjs-rails', '~> 2.10.6'
gem 'bootstrap3-datetimepicker-rails', '~> 4.17.37'

# magouille bdd david
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

#Sans la Gem Erreur concernant les Images_Tags
gem 'coffee-script-source', '1.8.0'


# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'bigbluebutton_rails', github: 'mconf/bigbluebutton_rails'



gem 'resque', :require => "resque/server"

gem 'devise_lastseenable'

gem "factory_girl_rails", "~> 4.0"

gem 'capybara' #Pour les test

gem "rails-erd"
# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  #gem 'byebug'
  gem 'sqlite3', '1.3.11'
  gem 'byebug',      '3.4.0'

  gem 'sunspot_solr'
  gem 'rspec-rails', '~> 3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

group :production do
  gem 'pg',             '0.17.1'
  gem 'rails_12factor', '0.0.2'
end

