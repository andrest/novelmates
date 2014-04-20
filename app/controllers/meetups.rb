# Contains Meet-up specific routes
Novelmates::App.controllers :meetup do

  post :update do
    halt 401 unless signed_in?
    event = Meetup.where(creator: params[:user_id]).find(params[:id]) 
    params['venue'] = MultiJson.decode(params['venue']) if params.key?('venue')
    if !event.nil? && event.update_attributes(params)
      redirect request.env["HTTP_REFERER"];
    else
      flash[:error] = 'Something went wrong. ' + event.errors.full_messages.join('. ') unless event.nil?
      redirect request.env["HTTP_REFERER"]
    end
  end

  post :attending do
    halt 401 unless signed_in?
    meetup = Meetup.find(params[:meetup_id])
    if params[:attending] == 'true'
      current_user.meetups.push(meetup)
      send_notifications meetup
    else
      meetup.pull(:user_ids, current_user._id)
      current_user.pull(:meetup_ids, meetup._id)
    end
    status 200
  end

  post :notify do
    halt 401 unless signed_in?
    meetup = Meetup.find(params[:meetup_id])
    if params[:notify] == 'true'
      meetup.notify_ids << current_user._id
      meetup.save
    else
      meetup.pull(:notify_ids, current_user._id)
    end
    status 200
  end

  post :create do
    halt 401 unless signed_in?
    params.delete :topic
    params[:notify_ids] = [ current_user._id ] if params[:notification] == 'true'
    params.delete :notification
    params[:user_ids] = [ params[:creator] ]
    event = Meetup.new(params)
    if event.save
      redirect '/meetup/' + event._id + '/for/' + event.books
    else
      flash[:error] = 'Something went wrong. ' + event.errors.full_messages.join('. ')
      redirect request.env["HTTP_REFERER"]
    end
  end

  get :index, map: '/meetup/:id/for/:isbn' do
    @meetup = Meetup.find params[:id]
    @book = BookController.get_book(params[:isbn])
    @users = User.where(meetup_ids: @meetup._id)
    @attendants = @users.map { |u| u._id }
    @interests = Interest.where(isbn: params[:isbn]).in(user_ids: @attendants)

    @additional_css = stylesheet_link_tag "meetup"
    @additional_js  = javascript_include_tag  "book" 
    @additional_js  += javascript_include_tag "meetups"
    render '/meetups/meetup'
  end

  # Pattern: /city/isbn/title
  # E.g. /london/97029384567/the-lies-of-lock-lamora
  get :meetups, :map => '/meetups/at/:location/for/:isbn/:title' do
    pass unless 0 == (/[\d\s]*\z/ =~ params[:location])
    pass unless 0 == (/((97(8|9))?\d{9}(?:(\d|X)))(\s\z)?/ =~ params[:isbn])
    pass unless 0 == (/[\w|-]*\z/ =~ params[:title])

    cities = params[:location]
    isbns   = params[:isbn].split(' ')
    @books = isbns.map { |isbn| BookController.get_book(isbn) }
    @books.each do |book|
      class << book
        attr_accessor :meetups
        attr_accessor :interests
      end
      book.meetups = Meetup.where({:'books' => book.isbn})
      book.interests = Interest.where(isbn: book.isbn).ne(user_ids: []).all.entries
    end
    
    @additional_css = stylesheet_link_tag("book")
    @additional_js  = javascript_include_tag  "book"
    erb:'books/book'
  end
end
