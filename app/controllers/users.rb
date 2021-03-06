# Contains user specific routes
Novelmates::App.controllers :user do

  get :profile_pic, map: '/user/:id/profile_pic' do
    if !current_user.nil? && params[:id].to_s == current_user._id.to_s
      user = current_user
    else
      user = User.find(params[:id])

      if user.nil?
        return '<img style="display:inline-block;" class="profile img-circle" src="http://placekitten.com/40/40">'
      end
    end

    profile_pic = ''
    if (user.profile == nil)
      initials = user.firstname[0] + user.lastname[0];
      initials.upcase!
      style = 'style="line-height: 40px; display: inline-block;text-align: center;vertical-align: middle; border-radius: 50%; width: 40px; height: 40px;background: rgb(172, 172, 172);"'
      span = '<a href="/user/'+params[:id]+'"><span class="" '+style+'>'+initials+'</span></a>'
      profile_pic = '<div class="profile img-circle">'+span+'</div>'
    else
      pic = '<img style="display:inline-block;" class="profile img-circle" src="' + user.profile + '">'
      link = '<a href="/user/'+params[:id]+'">'+pic+'</a>'
      profile_pic = link
    end
    profile_pic
  end

  get :profile do
    if signed_in?
      call env.merge('PATH_INFO' => '/user/'+ current_user._id)
    else
      halt 403
    end
  end

  get :edit do
    redirect '/' unless signed_in?
    @user = current_user
    render 'user/edit'
  end

  post :edit do
    halt 401 unless signed_in?
    @user = current_user
    @user.update_attributes(params)
    render 'user/edit'
  end

  post :link, :map => 'user/facebook/link' do
    halt 401 unless signed_in?
    warden.authenticate!(:facebook)

  end

  post :unlink, :map => 'user/facebook/unlink' do
    halt 401 unless signed_in?

    current_user.FBTokens.delete
    current_user['profile'] = nil
    current_user.save
    status 200
  end

  get :index, with: :id do
    @user = User.find(params[:id])
    halt 404 if @user.nil?
    
    @meetups_created = Meetup.where(creator: @user._id)
    @meetups = Meetup.where(user_ids: @user._id).ne(creator: @user._id)
    @additional_js  = javascript_include_tag "user"
    render 'user/index'
  end
end
