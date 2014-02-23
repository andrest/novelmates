require 'sinatra/base'

module Sinatra
	module Routes
		module Helpers
  			def dev?
  				ENV['RACK_ENV'] = 'development'
  			end
		end
	

		def self.registered(app)
			app.helpers Routes::Helpers

			app.get "/" do
				@title              = "Novelmat.es -- novel way to gain insight in books read"
				uri                 = URI.parse('http://freegeoip.net/json/')
				http                = Net::HTTP.new(uri.host, uri.port)
				response            = http.request(Net::HTTP::Get.new(uri.request_uri))
				resp                = JSON.parse(response.body)
				session['location'] = resp["city"].downcase!
				# c = GeoIP.new('GeoLiteCity.dat').country('94.197.121.225')
				# puts c.to_hash
				erb :index
			end

			app.get "/profile" do
				halt(401,'Not Authorized') unless auth?
				"This is the private page - members only"
			end

			app.post '/login' do
				request.env['warden'].authenticate!
				p ENV['warden'].user if dev?
				redirect '/'
			end

			app.get '/login' do
				erb :login, :locals => {:scope => ENV['FB_SCOPE']}
			end

			app.get '/logout' do
		    	env['warden'].raw_session.inspect if dev?
		    	env['warden'].logout
		    	redirect '/'
		  	end

			app.get '/signup' do 
				erb :signup, :layout => false
			end

			app.post '/signup' do
				u = User.new(params)
				p u if dev?
				u.save
				if u.save
					redirect '/'
				else
					p "Error saving user" if dev?
				end
			end

			app.get '/session' do
				if defined?(ActiveSupport::JSON)
				  [Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
				    klass.class_eval do
				      def to_json(*args)
				        super(args)
				      end
				      def as_json(*args)
				        super(args)
				      end
				    end
				  end
				end
				content_type 'application/json'
				MultiJson.encode(request.env)
			end

			app.get '/auth/:provider/callback' do
				request.env['warden'].authenticate!(:facebook)
			    redirect '/'
			end

			app.get '/auth/failure' do
				content_type 'application/json'
				MultiJson.encode(request.env)
			end

			app.get "/mosaic" do
				books = BookController.get_books('cocktail')
				BookController.generate_mosaic(books)
			end

			app.get '/autocomplete/:term' do
				books = BookController.get_books(params[:term])
				BookController.generate_search_results(books)
			end
			
			app.get '/book/*' do
				"Page for book: #{params[:name]}"
				params.each do |s|
					puts "Parameter: #{s}"
				end
			end
			
			app.get '/location/:name' do
				"Page for book: #{params[:name]}"
				params.each do |s|
					puts "Parameter: #{s}"
				end
			end

			# Pattern: /city/isbn/title
			# E.g. /london/97029384567/the-lies-of-lock-lamora
			app.get %r{(?:/)(\w+)/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
				city = params[:captures][0]
				isbn = params[:captures][1]
				
				@book = BookController.get_book(isbn)
				p @book.title
				generator = Faker::SamuelLIpsum.new
				
				@additional_css = set_css "book"

				erb:book
			end

			app.get '/get_book/:isbn' do
				content_type 'application/json'
				MultiJson.encode(BookController.get_book(params[:isbn]))
			end
			
			app.get '/cookie' do
				halt unless dev?
			  	session['counter'] ||= 0
			  	session['counter'] += 1
			  	# puts session
				session.each do |s|
					#puts s.join(" ")
					puts "Parameter: #{s}"
				end
				ENV.inspect()
			end

			app.get '/test' do
				halt unless dev?
				ap request.env
				puts ''
				ap ENV.to_hash
			end
		end
	end
	register Routes
end