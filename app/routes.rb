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
        @title              = "Novelmates – novel way to gain insight in books read"
        @additional_js  = set_js  "index"
        erb :index
      end

      app.get '/city/auto/' do
        content_type 'application/json'
        # uri = URI.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json?types=(cities)&sensor=false&key=AIzaSyDs_k1wyceiD8D6l1ysl2dI-KVjFsr0ONk&input=' + params[:q])
        # body = Net::HTTP.get_response(uri).body
        # p body
        # results = MultiJson.load(body)['predictions']

        # final = []
        # results.each do |city|
        #   final.push( { 'id' => city['id'], 'name' => city['description'] } )
        # end

        # MultiJson.encode(final)
        countryBias = (cookies['country_ip'])? '&countryBias='+cookies['country_ip'] : ''
        uri = URI.parse('http://ws.geonames.org/searchJSON?username=novelmates&featureClass=P&maxRows=10&name_startsWith='+URI::encode(params[:q])+countryBias)
        body = Net::HTTP.get_response(uri).body
        results = MultiJson.load(body)["geonames"]

        final = []
        results.each do |city|
          if (city['fcode'] =~ /PPL.*/)
            final.push( { 'id' => city['geonameId'], 'name' => city['name']+', '+city['countryName'] } )
          end
        end

        MultiJson.encode(final)
        # results
      end

      app.get '/geoip' do
        ip = '159.92.9.130'
        ip = request.ip unless request.ip == '127.0.0.1'

        # puts "HELLO " + ip
        # c = GeoIP.new('GeoLiteCity.dat').country(ip)
        # MultiJson.encode(c.to_hash)

        uri = URI.parse('http://freegeoip.net/json/' + ip)
        res =MultiJson.load( Net::HTTP.get_response(uri).body )

        response.set_cookie 'country_ip',
        {:value=> res['country_code'], :max_age => "64800"}
        response.set_cookie 'city_ip',
        {:value=> res['city'] + ", " + res['country_name'], :max_age => "2592000"}

        res['city']+', '+res['country_name']
      end

      app.get "/profile" do
        halt(401,'Not Authorized') unless auth?
        "This is the private page - members only"
      end

      app.post '/login' do
        request.env['warden'].authenticate!
        redirect '/'
      end

      app.get '/login' do
        erb :login, :locals => {:scope => ENV['FB_SCOPE']}
      end

      app.get '/logout' do
        env['warden'].logout
        redirect '/'
      end

      app.get '/signup' do 
        erb :signup, :layout => false
      end

      app.post '/signup' do
        u = User.new(params)
        logger.info u if dev?
        u.save
        if u.save
          redirect '/'
        else
          logger.info "Error saving user" if dev?
        end
      end

      # app.get '/session' do
      #   if defined?(ActiveSupport::JSON)
      #     [Object, Array, FalseClass, Float, Hash, Integer, NilClass, String, TrueClass].each do |klass|
      #       klass.class_eval do
      #         def to_json(*args)
      #           super(args)
      #         end
      #         def as_json(*args)
      #           super(args)
      #         end
      #       end
      #     end
      #   end
      #   content_type 'application/json'
      #   MultiJson.encode(request.env)
      # end

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
      
      # app.get '/book/*' do
      #   "Page for book: #{params[:name]}"
      #   params.each do |s|
      #     puts "Parameter: #{s}"
      #   end
      # end
      
      # app.get '/location/:name' do
      #   "Page for book: #{params[:name]}"
      #   params.each do |s|
      #     puts "Parameter: #{s}"
      #   end
      # end

      # Pattern: /city/isbn/title
      # E.g. /london/97029384567/the-lies-of-lock-lamora
      app.get %r{([\d\+]+)/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
        # app.get %r{(?:/)([\d\+])+/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
        # http://ws.geonames.org/getJSON?formatted=false&geonameId=588335&username=novelmates&style=short
        city = params[:captures][0].split('+')
        isbn = params[:captures][1]

        @book = BookController.get_book(isbn)
        
        @additional_css = set_css "book"
        @additional_js  = set_js  "book"
        erb:book
      end

      app.get '/get_book/:isbn' do
        content_type 'application/json'
        MultiJson.encode(BookController.get_book(params[:isbn]))
      end
      
      # app.get '/cookie' do
      #   halt unless dev?
      #   session['counter'] ||= 0
      #   session['counter'] += 1
      #     # puts session
      #     session.each do |s|
      #     #puts s.join(" ")
      #     puts "Parameter: #{s}"
      #   end
      #   ENV.inspect()
      # end

      # app.get '/test' do
      #   halt unless dev?
      #   ap request.env
      #   puts ''
      #   ap ENV.to_hash
      # end
    end
  end
  register Routes
end