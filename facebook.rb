require 'omniauth-facebook'
 
Warden::Strategies.add(:facebook) do
  def valid?
	request.cookies['fbsr_'+ENV['APP_ID']] or params["code"]
  end
 
  def authenticate!


    # return fail!('You have not accepted to assign your acount with example.com') if params[:error_reason]
 	fb_user = request.env['omniauth.auth']
    access_token = fb_user['credentials']['token']
    u = User.where(:oauth => { "facebook" => fb_user['uid'] }, :active => true).first

   	if u.nil?
		u = User.new(email: fb_user['info']['email'], firstname: fb_user['info']['first_name'],lastname: fb_user['info']['last_name'], oauth: {facebook: fb_user['uid']})
		u.save
		if u.save
			p 'user saved'
		else
			p "error saving user"
			fail!("Error saving user")
		end
	end
	token = FB_Token.where(uid: fb_user['uid'])
	token.delete unless token.nil?
	
	token = FB_Token.new(uid: fb_user['uid'], expires_at: fb_user['credentials']['expires_at'], token: fb_user['credentials']['token'] ).save
   	!success!(u)
  end
  
end

Warden::Strategies.add(:password) do
  def valid?
    params["email"] || params["password"]
  end
 
  def authenticate!
  	p "password auth"
    u = User.authenticate(params["email"], params["password"])
    u.nil? ? fail!("Could not log in") : success!(u)
  end
end