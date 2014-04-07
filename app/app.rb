module Novelmates
  class App < Padrino::Application
    register Padrino::Cache
    enable :caching

    register Authentication
    register LessInitializer
    register AWS
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    register Padrino::Sprockets
    sprockets minify: (Padrino.env == :production)

    enable :sessions
    enable :reload

    Resque.redis = RedisConnection.connection
    Mongoid.load!("mongoid.yml")

    # Grab the cities from the URL if it contains /at/123213+1232
    before /\/at\// do
      url = request.env["PATH_INFO"]
      locations = url.match(/at\/([\d|\+]+)\//i).captures[0].split('+')
      session[:url_cities] = locations
    end

    get "/" do
      @title= 'Novelmates'
      @additional_css = stylesheet_link_tag Rack::Less.stylesheet('index')
      @additional_js  = javascript_include_tag  "index"
      erb :index
    end

    post '/unauthenticated' do
      flash[:warning] = "Invalid login credentials"
      redirect request.env['HTTP_REFERER']
    end

    post '/locations/update' do
      locations = MultiJson.decode(params[:locations])
      session[:current_cities] = locations
      return 'ok'
    end

    get '/geo/:address' do
      content_type 'application/json'

      uri = URI.parse('http://ws.geonames.org/searchJSON?username=novelmates&featureClass=P&maxRows=3&q='+URI::encode(params[:address]))
      body = Net::HTTP.get_response(uri).body
      results = MultiJson.load(body)["geonames"]
      final = []
      final.push( { 'id' => results[0]['geonameId'], 'name' => results[0]['name']+', '+ results[0]['countryName'] } )

      MultiJson.encode(final)
    end

    get '/city/auto/' do
      content_type 'application/json'

      cookies = request.cookies
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
    end

    get '/city/id/:id' do
      content_type 'application/json'

      uri = URI.parse('http://api.geonames.org/getJSON?formatted=true&username=novelmates&style=short&geonameId='+URI::encode(params[:id]))
      body = Net::HTTP.get_response(uri).body
      results = MultiJson.load(body)
      final = {id: results['geonameId'], name: results['name'] + ', ' + results['countryName']};

      MultiJson.encode(final)
    end

    get '/geoip' do
      ip = '159.92.9.130'
      ip = request.ip unless request.ip == '127.0.0.1'

      uri = URI.parse('http://freegeoip.net/json/' + ip)
      res =MultiJson.load( Net::HTTP.get_response(uri).body )

      response.set_cookie 'country_ip',
      {:value=> res['country_code'], :max_age => "64800"}

      call env.merge('PATH_INFO' => '/geo/'+ URI::encode(res['city']+', '+res['country_name']))
    end

    post '/login' do
      request.env['warden'].authenticate!
      if request.env["PATH_INFO"] != "/signup"
        redirect request.env['HTTP_REFERER']
      else
        redirect '/'
      end
    end

    get '/login' do
      erb :login, :locals => {:scope => ENV['FB_SCOPE']}
    end

    get '/logout' do
      env['warden'].logout
      redirect request.env['HTTP_REFERER']
    end

    get '/signup' do 
      erb :signup, :layout => true
    end

    post '/signup' do
      u = User.new(params)
      u.save
      if u.save
        call env.merge('PATH_INFO' => '/login')
      else
        flash[:error] = u.errors.full_messages
        render 'signup'
      end
    end

    get '/auth/:provider/callback' do
      request.env['warden'].authenticate!(:facebook)
      redirect request.env['HTTP_REFERER']
    end

    get '/auth/failure' do
      content_type 'application/json'
      MultiJson.encode(request.env)
    end

    get "/mosaic" do
      books = BookController.get_books('tequila')
      BookController.generate_mosaic(books)
    end

    get "/mosaic/:id" do
      if !params[:id].nil?
        isbns = Meetup.where(city: params[:id]).distinct(:books)
        isbns = isbns[0..9]
        books = BookController.lookup_books(isbns)
      else
        books = BookController.get_books('cocktails')
      end

      BookController.generate_mosaic(books)
    end

    get '/autocomplete' do
      content_type 'application/json'

      books = BookController.get_books(params[:q])
      BookController.generate_search_results(books)
    end

    get '/email' do
      @meetups = Meetup.in(user_ids: ['5333014e2cf31089e7000001']).all.entries
      erb :email, layout: false
    end
    
    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache.new(:LRUHash) # Keeps cached values in memory
    # set :cache, Padrino::Cache.new(:Memcached) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Memcached, '127.0.0.1:11211', :exception_retry_limit => 1)
    # set :cache, Padrino::Cache.new(:Memcached, :backend => memcached_or_dalli_instance)
    # set :cache, Padrino::Cache.new(:Redis) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Redis, :host => '127.0.0.1', :port => 6379, :db => 0)
    # set :cache, Padrino::Cache.new(:Redis, :backend => redis_instance)
    # set :cache, Padrino::Cache.new(:Mongo) # Uses default server at localhost
    # set :cache, Padrino::Cache.new(:Mongo, :backend => mongo_client_instance)
    # set :cache, Padrino::Cache.new(:File, :dir => Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #
  end
end
