require 'omniauth-facebook'

module Authentication
  def self.registered(app)
    app.use Warden::Manager do |manager|
        manager.default_strategies :password, :facebook
        manager.failure_app = app
        manager.serialize_into_session {|user| user._id}
        manager.serialize_from_session {|id| p id; User.find(Moped::BSON::ObjectId(id.to_s)) }
        # manager.serialize_from_session {|id| User.find( {_id:ObjectId(id)} ) }
    end
     
    Warden::Manager.before_logout do |user,auth,opts|
      auth.cookies.delete :login
    end
    app.use OmniAuth::Builder do
      provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], {:scope => ENV['SCOPE'], :provider_ignores_state => true}
    end
  end


  Warden::Strategies.add(:facebook) do
    def valid?
     request.cookies['fbsr_'+ENV['APP_ID']] or params["code"]
    end
   
    def authenticate!
      fb_user = request.env['omniauth.auth']
      access_token = fb_user['credentials']['token']
      u = User.where(:oauth => { "facebook" => fb_user['uid'] }, :active => true).first

      if u.nil?
      u = User.new(email: fb_user['info']['email'], firstname: fb_user['info']['first_name'],lastname: fb_user['info']['last_name'], oauth: {facebook: fb_user['uid']})
      u.save
      if u.save
        logger.info 'user saved' if dev?
      else
        logger.info "error saving user" if dev?
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
      u = User.authenticate(params["email"], params["password"])
      u.nil? ? fail!("Could not log in") : success!(u)
    end
  end
end