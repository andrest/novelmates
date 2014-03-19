require 'omniauth-facebook'

module Authentication
  def self.registered(app)
    app.use Warden::Manager do |manager|
        manager.default_strategies :password, :facebook
        manager.failure_app = app
        manager.serialize_into_session {|user| user._id}
        manager.serialize_from_session {|id| User.find(Moped::BSON::ObjectId(id.to_s)) }
        # manager.serialize_from_session {|id| User.find( {_id:ObjectId(id)} ) }
    end
     
    Warden::Manager.before_logout do |user,auth,opts|
      auth.cookies.delete :login
    end
    Warden::Manager.after_authentication do |user, auth, opts|
      p 'after warden auth..'
    end
    app.use OmniAuth::Builder do
      provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], {:scope => ENV['SCOPE'], :provider_ignores_state => true}
    end
  end


  Warden::Strategies.add(:facebook) do
    def valid?
     request.cookies['fbsr_'+ENV['APP_ID']] or params["code"]
    end
    def dev?
      ENV['RACK_ENV'] = 'development'
    end
   
    def authenticate!
      fb_user = request.env['omniauth.auth']
      access_token = fb_user['credentials']['token']
      # ap fb_user
      u = User.where(:"FBTokens.uid" => fb_user['uid'], :active => true).first
      # ap u
      if u.nil?
        u = User.new(email: fb_user['info']['email'], firstname: fb_user['info']['first_name'],lastname: fb_user['info']['last_name'], profile: fb_user['info']['image'], location: {fb: fb_user['info']['location']})
        # p 1
        # ap u
        u.FBTokens = FBToken.new(uid: fb_user['uid'], token: access_token)
        # p 2
        # ap u
        u.save

        if u.save
          logger.info 'user saved' if dev?
        else
          logger.info u.errors.full_messages if dev?
          throw(:warden)
          fail!("Error saving user")
        end
      end
      # ap u
      !success!(u)
    end

    # token = FBToken.where(uid: fb_user['uid'])
    # token.delete unless token.nil?
    
    # token = FBToken.new(uid: fb_user['uid'], expires_at: fb_user['credentials']['expires_at'], token: fb_user['credentials']['token'] ).save
    #   !success!(u)
    # end
    
  end

  Warden::Strategies.add(:password) do
    def valid?
      params["email"] || params["password"]
    end
   
    def authenticate!
      u = User.authenticate(params["email"], params["password"])
      ap params
      u.nil? ? fail!("Could not log in") : success!(u)
    end
  end
end