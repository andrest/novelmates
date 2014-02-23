require 'rubygems'
require 'sinatra'
require 'erb'
require 'net/http'
require 'json'
require 'nokogiri'
require 'blasphemy'
require 'omniauth-facebook'
require 'rack-flash'
require 'geoip'

require 'warden'
require 'mongoid'

#set :raise_errors, true
#set :dump_errors, false
#set :show_exceptions, false
require_relative 'helpers'
require_relative 'aws'
require_relative 'routes'
require_relative './controllers/book_controller'

require_relative './models/user'
require_relative './models/book'
require_relative 'facebook'
require_relative 'environment'

configure do
	enable :sessions
	enable :logging
	set :bind, '0.0.0.0'
	set :protection, :except => :frame_options
	set :session_secret, ENV['SESSION_SECRET']
	Mongoid.load!("mongoid.yml")

	use Warden::Manager do |manager|
	    manager.default_strategies :password, :facebook
	    manager.failure_app = MyApp
	    manager.serialize_into_session {|user| user._id}
	    manager.serialize_from_session {|id| p id; User.find(Moped::BSON::ObjectId(id.to_s)) }
	    # manager.serialize_from_session {|id| User.find( {_id:ObjectId(id)} ) }
	end
	 
	Warden::Manager.before_logout do |user,auth,opts|
	  auth.cookies.delete :login
	end
	use OmniAuth::Builder do
		provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], {:scope => ENV['SCOPE'], :provider_ignores_state => true}
	end
end

class MyApp < Sinatra::Application
	register Sinatra::Routes
	register Sinatra::AWS
	register Sinatra::BookController


	include Rack::Utils
	alias_method :h, :escape_html
end
