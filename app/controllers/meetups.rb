Novelmates::App.controllers :meetup do
  
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
    ap event

    ap params
    if !event.nil? && event.update_attributes(params)
      redirect request.env["HTTP_REFERER"];
    else
      "Messed up babe, sorry!"
    end
  end

  post :create do
    params[:books] = [ params[:books] ]
    params.delete :topic
    params.delete :notification

    event = Meetup.new(params)
    ap params
    if event.save
      redirect '/meetup/' + event._id + '/' + event.books.join('+')
    else
      "Messed up babe, sorry!"
    end
  end
  
  get :index, with: [:id] do
    p "Meetup for " + params[:id]
    @meetup = Meetup.find params[:id]
    ap @meetup
    render '/meetups/meetup'
  end

  get :index, with: [:id, :isbn] do
    p "Meetup for " + params[:id]

    @meetup = Meetup.find params[:id]
    @book = BookController.get_book(params[:isbn])

    @additional_css = stylesheet_link_tag "meetup"
    @additional_js  = javascript_include_tag  "book"
    render '/meetups/meetup'
  end

  get :show do
    p "show"
  end

  post :create, with: [:locations, :id] do
    p params[:locations] + " " + params[:id]
  end

end
