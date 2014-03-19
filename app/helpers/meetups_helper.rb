# Helper methods defined here can be accessed in any controller or view in the application

Novelmates::App.helpers do
  def attending?
    return false if !signed_in?
    return false if meetups?
    @attendants.include? current_user._id
  end

  def meetup?
    if (defined? @meetup) == nil
      false
    else
      true
    end
  end

  def meetups?
    !meetup?
  end
end
