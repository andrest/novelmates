# Helper methods defined here can be accessed in any controller or view in the application

Novelmates::App.helpers do
  def signed_in?
    !current_user.nil?
  end

  def current_user
    warden.user
  end

  # def current_user.profile
  #   if current_user.profile == nil
  #     current_user.profilecurrent_user[:_id]
  # end

  def warden
    request.env['warden']
  end

  def authenticate!
    warden.authenticate!
  end
end
