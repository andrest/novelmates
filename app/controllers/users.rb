Novelmates::App.controllers :user do
  
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
  
  get :index do
    p 'yo'
  end

  get :profile_pic, map: '/user/:id/profile_pic' do

    if !current_user.nil? && params[:id].to_s == current_user._id.to_s
      user = current_user
      # ap 'CURRENT USER'
    else
      user = User.find(params[:id])

      if user.nil?
        return '<img style="display:inline-block;" class="profile img-circle" src="http://placekitten.com/40/40">'
      end
      # return if user.nil?
      # ap "OTHER USER"
    end

    profile_pic = ''
    if (user.profile == nil)
      initials = user.firstname[0] + user.lastname[0];
      initials.upcase!
      style = 'style="line-height: 40px; display: inline-block;text-align: center;vertical-align: middle; border-radius: 50%; width: 40px; height: 40px;background: rgb(172, 172, 172);"'
      span = '<a href="/user/'+params[:id]+'"><span class="" '+style+'>'+initials+'</span></a>'
      profile_pic = '<div class="profile img-circle">'+span+'</div>'
    else
      profile_pic = '<img style="display:inline-block;" class="profile img-circle" src="' + user.profile + '">'
    end
    profile_pic
  end

  get :books do
    erb 'list all the user\'s books'
  end

  get :profile do
    if signed_in?
      call env.merge('PATH_INFO' => '/user/'+ current_user._id)
    else
      halt 403
    end
  end

  get :edit do
    halt unless signed_in?
    @user = current_user
    render 'user/edit'
  end

  get :index, with: :id do
    # if params[:id] == current_user._id
    #   @user = current_user
    # else
    @user = User.find(params[:id])

    @meetups_created = Meetup.where(creator: @user._id)
    @meetups = Meetup.where(user_ids: @user._id).ne(creator: @user._id)

    render 'user/index'
  end
end
