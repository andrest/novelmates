Novelmates::App.controllers :meetup do
  # <ol class="breadcrumb">
  #   <li><a href="#">Home</a></li>
  #   <li>
  #     <% session[:url_cities].each do |city| %>
  #       <a href="#"><%= city %></a>
  #     <% end %>
  #   </li>
  #   <li class="active"><a href="/meetups/at/<%= session[:url_cities].join('+') %>/for/<%= @book.isbn+'/'+@book.get_url_title %>"><%= @book.title %></a></li>
  #   <li class="active"><%= @meetup.name %></li>
  # </ol>

  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end

  post :update do
    event = Meetup.where(creator: params[:user_id]).find(params[:id]) 
    # ap event

    params['venue'] = MultiJson.decode(params['venue'])
    # params.delete(:venue)
    # ap params
    if !event.nil? && event.update_attributes(params)
      redirect request.env["HTTP_REFERER"];
    else
      flash[:error] = 'Something went wrong. Did you create the event?'
      redirect request.env["HTTP_REFERER"]
    end
  end

  post :attending do
    ap params
    meetup = Meetup.find(params[:meetup_id])
    if params[:attending] == 'true'
      current_user.meetups.push(meetup)
    else
      meetup.pull(:user_ids, current_user._id)
      current_user.pull(:meetup_ids, meetup._id)
    end
    return
  end

  post :create do
    params["books"] = [ params[:books] ]
    params.delete :topic
    params.delete :notification

    event = Meetup.new(params)
    ap params
    if event.save
      redirect '/meetup/' + event._id + '/for/' + event.books.join('+')
    else
      flash[:error] = 'Something went wrong. Did you create the event?'
      redirect request.env["HTTP_REFERER"]
    end
  end
  
  # get :index, with: [:id] do
  #   p "Meetup for " + params[:id]
  #   @meetup = Meetup.find params[:id]
  #   @interests = Interest.where(isbn: '0762448652').all.entries
  #   ap @meetup
  #   render '/meetups/meetup'
  # end

  get :index, map: '/meetup/:id/for/:isbn' do

    @meetup = Meetup.find params[:id]
    @book = BookController.get_book(params[:isbn])
      # ap 'Name'
      # ap @meetup.name
    @users = User.where(meetup_ids: @meetup._id)
      # ap @users
    @attendants = @users.map { |u| u._id }
      # ap 'Meetup users: ' ; ap @attendants
      # ap 'Users: '; @users.to_a #.each { |i| puts i.firstname + ' ' + i._id }
      # ap 'Interests: '; ap Interest.where(isbn: params[:isbn]).to_a
    @interests = Interest.in(user_ids: @attendants).where(isbn: params[:isbn])
      # ap 'INTERESTS:: '
      # ap @interests.build(user_ids: @users.map { |u| u._id }).to_a
    # ap attending?
    # p '---'
    # ap @attendants
    # ap Meetup.find(@meetup._id).user_ids.to_a
    # p '+++'
    # ap current_user._id
    # @interests.assign_attributes(user_ids: @attendants)
      # @interests.each { |i| puts i.category }
      # ap @interests.to_a
    # @attending = false
    # if signed_in? 
    #   @attending = Meetup.where({_id: @meetup._id, user_ids: current_user._id}).exists?
    # end

    @additional_css = stylesheet_link_tag "meetup"
    @additional_js  = javascript_include_tag  "book" 
    @additional_js  += javascript_include_tag "meetups"
    render '/meetups/meetup'
  end

  get :show do
    p "show"
  end

  post :create, with: [:locations, :id] do
    p params[:locations] + " " + params[:id]
  end

    # Pattern: /city/isbn/title
  # E.g. /london/97029384567/the-lies-of-lock-lamora
  # get %r{/([\d\+]+)/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
  get :meetups, :map => '/meetups/at/:location/for/:isbn/:title' do
    pass unless 0 == (/[\d\s]*\z/ =~ params[:location])
    pass unless 0 == (/((97(8|9))?\d{9}(?:(\d|X)))\z/ =~ params[:isbn])
    pass unless 0 == (/[\w|-]*\z/ =~ params[:title])

    # get %r{(?:/)([\d\+])+/((97(8|9))?\d{9}(?:(\d|X)))/([\w|-]*)} do
    # http://ws.geonames.org/getJSON?formatted=false&geonameId=588335&username=novelmates&style=short
    cities = params[:location]
    isbn   = params[:isbn]

    @book = BookController.get_book(isbn)
    @meetups = Meetup.where({:'books' => isbn})
    @interests = Interest.where(isbn: isbn).ne(user_ids: []).all.entries

    # city = http://api.geonames.org/getJSON?formatted=true&geonameId=588335&username=novelmates&style=short
    
    @additional_css = stylesheet_link_tag("book")
    @additional_js  = javascript_include_tag  "book"
    erb:'books/book'
  end

end
