require 'rubygems' 
require 'bundler'  
Bundler.require
Dotenv.load

Dir[File.dirname(__FILE__) + '/models/**/*.rb'].each do |file|
	require file
end
Dir[File.dirname(__FILE__) + '/controllers/**/*.rb'].each do |file|
	require file
end

require './app/routes'


Dir[File.dirname(__FILE__) + '/app/**/*.rb'].each do |file|
	require file unless file == File.dirname(__FILE__) + '/app/app.rb'
end

require ::File.dirname(__FILE__) + '/app/app.rb'

run MyApp