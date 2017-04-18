source 'https://rubygems.org'


gem 'rails', '~> 5.0.0'

gem 'sass-rails'
gem 'turbolinks', '~> 5.0'
gem 'jbuilder', '~> 2.5'

gem 'bcrypt', '~> 3.1.7'

# Third-party gems
gem 'aws-sdk', '~> 2.3'
gem 'countries', '~> 1.2', require: 'countries/global'
gem 'foundation-rails', '~> 5.5'
gem 'haml', '~> 4.0'
gem 'http', '~> 2.0'
gem 'paperclip', '~> 5.0'
gem 'pg'
gem 'prawn', '~> 2.1'
gem 'prawn-svg'
gem 'redcarpet', '~> 3.3', require: false
gem 'strip_attributes', '~> 1.7'
gem 'stripe'
gem 'twilio-ruby', '~> 4.1'
gem 'vanilla-ujs'

# Custom gems
gem 'dropbox-sdk-v2', '~> 0.0.2', require: 'dropbox'

group :development do
  gem 'puma'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  gem 'listen'
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :development, :test do
  gem 'rails-controller-testing'
end

group :test do
  gem 'webmock'
end

group :production do
  gem 'closure-compiler'
  gem 'unicorn'
end
