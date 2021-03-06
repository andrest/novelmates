source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'

# Component requirements
gem 'therubyracer'
gem 'rack-less'
gem 'less'
gem 'erubis', '~> 2.7.0'
gem 'mongoid', '~>3.0.0'

# Test requirements

# Padrino Stable Gem
gem 'padrino', '0.12.0'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.12.0'
# end

group :production do
  ruby '2.1.0'
  gem 'unicorn'
  # enable js minification
  gem 'uglifier'
  # enable css compression
  gem 'yui-compressor'
end

group :development do
  gem 'rails-erd'
  gem 'faker'
end

group :test do
  gem "rspec"
  gem 'factory_girl'
  gem 'simplecov', :require => false
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'mongoid-rspec'
  gem 'rack-test', :require => 'rack/test'

end
gem 'faker'
gem 'capybara'
gem 'poltergeist'
gem 'resque', :require => 'resque/server'

gem 'mail'
gem 'padrino-sprockets', :require => ['padrino/sprockets'], :git => 'git://github.com/nightsailer/padrino-sprockets.git'
gem "sprockets-less"
# gem 'htmlentities'
gem 'json'
gem 'nokogiri'
gem 'blasphemy'
gem 'omniauth-facebook'
gem 'geoip'

gem 'warden'
gem "awesome_print"

gem 'uuid'
gem 'bcrypt'

gem 'dotenv'