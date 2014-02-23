require 'sinatra/base'

module Sinatra
	module Routes
		module Helpers
			def auth?
				session[:auth]
			end

  			def protected! ; halt [ 401, 'Not Authorized' ] unless auth? ; end


			def searchBooks(searchTerm, imageSize = "Medium")
				aUri = URI.parse("http://webservices.amazon.com/onca/xml")
				parameters = { 
					"Service"          => "AWSECommerceService",
					"AWSAccessKeyId"   => ENV['AWS_ACCESS_KEY'],
					"AssociateTag"     => "place",
					"Operation"        => "ItemSearch",
					"Power"            => "language:english and not(spanish or italian or french or hebrew) and title: not(books OR box OR set OR trilogy OR 1- OR collector*) and " + searchTerm + "* and binding:-kindle -audio",
					"SearchIndex"      => "Books",
					"Sort"             => "salesrank",
					"ItemPage"         => "1",
					"ResponseGroup"    => "Medium",
					"Timestamp"        => AWS.current_time.getutc.iso8601,
					"SignatureVersion" => '2' }
				
				Sinatra::AWS.set_config
				res = AWS.do_query("GET", aUri, parameters)
				doc = Nokogiri::XML(res.body)
				doc.remove_namespaces!
				parseSearch(doc, imageSize)
			end

			def parseSearch(doc, imageSize = "Medium")
				newDoc = Nokogiri::XML::Document.new
				rootNode = Nokogiri::XML::Node.new("Items", newDoc)
				#first = doc.ItemSearchResponse.Items.Item.first
				doc.css("ItemSearchResponse Items Item").each do |item|
					if item.css('ItemAttributes ISBN').empty? then next end
					itemNode = Nokogiri::XML::Node.new("Item", rootNode)
			
					itemNode << item.css('ASIN')                		 unless item.css('ASIN').empty?
					itemNode << item.css('DetailPageURL') 			 	 unless item.css('DetailPageURL').empty?
					itemNode << item.css('ItemAttributes Author') 	     unless item.css('ItemAttributes Author').empty?
					itemNode << item.css('ItemAttributes ISBN')     	 unless item.css('ItemAttributes ISBN').empty?
					itemNode << item.css('ItemAttributes Title')     	 unless item.css('ItemAttributes Title') .empty?
					itemNode << item.at_css('ImageSets '+imageSize+'Image URL') unless item.css('ImageSets MediumImage URL').empty?
					
					rootNode << itemNode
				end	
				newDoc << rootNode
				newDoc
				content_type 'application/xml'
				doc
			end

			def lookUpBook(isbn)
				aUri = URI.parse("http://webservices.amazon.com/onca/xml")
				parameters = { 
					"Service"          => "AWSECommerceService",
					"AWSAccessKeyId"   => ENV['AWS_ACCESS_KEY'],
					"AssociateTag"     => "placeholder",
					"Operation"        => "ItemLookup",
					"SearchIndex"      => "Books",
					"IdType"           => "ISBN",
					"ItemId"           => isbn,
					"ResponseGroup"    => "Medium",
					"Timestamp"        => AWS.current_time.getutc.iso8601,
					"SignatureVersion" => '2' }
				#p self.class.ancestors
				AWS.set_config
				res = AWS.do_query("GET", aUri, parameters)
				doc = Nokogiri::XML(res.body)
			end

			# def makeMosaic(books)
			# 	@booksHTML = ""
			# 	books.css("Items Item").each do |book|
			# 		cover = book.at_css('URL').nil? ? "" : book.at_css('URL').text()
			# 		title = book.at_css('Title').nil? ? "" : book.at_css('Title').text()
			# 		author = book.at_css('Author').nil? ? "" : book.at_css('Author').text()
			# 		isbn = book.at_css('ISBN').nil? ? "" : book.at_css('ISBN').text()
			# 		@bookHTML = <<-HTML
			# 		<a href="/london/#{isbn}/#{title}">
			# 			<div class="cover-container">
			# 				<div class="cover">
			# 					<div class="front">
			# 						<img src="#{cover}" style="max-width:250px;"/>
			# 					</div>
			# 					<div class="back">
			# 						<span class="title"  style="display:block;"><h4>#{title}</h4></span>
			# 						<span class="author" style="display:block;">#{author}</span>
			# 						<span class="info" style="display:block;">#{rand(8)+1}</span>
			# 						<span class="text" style="display:block;">interested readers in your area</span>
			# 					</div>
			# 				</div>
			# 			</div>
			# 		</a>
			# 		HTML
			# 		@booksHTML << @bookHTML
			# 	end

			# 	<<-HTML
			# 	<div class="gallery center">
			# 		#{@booksHTML}
			# 	</div>
			# 	HTML
			# end
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

			app.get '/new' do 
				u = User.new(email: 'bana@got.com', password: 'testing')
				u.save
				if u.save
					p 'user saved'
				else
					p "Error saving user"
				end
			end

			app.get "/profile" do
				halt(401,'Not Authorized') unless auth?
				"This is the private page - members only"
			end

			app.post '/login' do
				request.env['warden'].authenticate!
				p env['warden'].user
				redirect '/'
			end

			app.get '/login' do
				flash[:notice] = "Thanks for signing up!"
				
				# session[:auth] = true

				erb :login, :locals => {:scope => SCOPE}
			end

			app.get '/logout' do
		    	env['warden'].raw_session.inspect
		    	env['warden'].logout
		    	redirect '/'
		  	end

			app.get '/signup' do 
				erb :signup, :layout => false
			end

			app.post '/signup' do
				u = User.new(params)
				p params
				p u
				u.save
				if u.save
					p 'user saved'
					redirect '/'
				else
					p "Error saving user"
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
			# app.get '/login' do
			#     env['warden'].authenticate!

			#     puts env['warden'].message

			#     if session[:return_to].nil?
			#       redirect '/'
			#     else
			#       redirect session[:return_to]
			#     end
		 #  	end
			 
			app.get '/logout' do
			  session[:auth] = nil
			  "You are now logged out"
			end

			app.get '/auth/:provider/callback' do
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
				request.env['warden'].authenticate!(:facebook)
			    # content_type 'application/json'
			    # x = request.env['warden']
			    # p x
			    # MultiJson.encode(request.env)
			    redirect '/'

			end

			app.get '/auth/failure' do
				content_type 'application/json'
				MultiJson.encode(request.env)
			end

			app.get "/mosaic" do
				# makeMosaic(searchBooks("harry", "Large"))
				books = BookController.get_books('cocktail')
				BookController.generate_mosaic(books)
			end

			app.get '/autocomplete/:term' do
				# searchBooks(params[:term]).to_s
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
				BookController.get_book(params[:isbn])
			end
			
			
			app.get '/cookie' do
			  	session['counter'] ||= 0
			  	session['counter'] += 1
			  	# puts session
				session.each do |s|
					#puts s.join(" ")
					puts "Parameter: #{s}"
				end
			end
		end
	end
	register Routes
end