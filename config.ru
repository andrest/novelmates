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

require './aws'
require './routes'
require './facebook'
require './helpers'
require './environment'

require ::File.join( ::File.dirname(__FILE__), 'app' )

run MyApp