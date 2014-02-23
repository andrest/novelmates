class MyApp < Sinatra::Application
	register Sinatra::Routes
	register Sinatra::AWS
	register Sinatra::BookController

	configure do
		enable :sessions
		enable :logging
		set :bind, '0.0.0.0'
		set :protection, :except => :frame_options
		set :session_secret, ENV['SESSION_SECRET']
		Mongoid.load!("mongoid.yml")

		file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  		file.sync = true
  		use Rack::CommonLogger, file

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

	include Rack::Utils
	alias_method :h, :escape_html
end
