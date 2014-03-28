# Helper methods defined here can be accessed in any controller or view in the application

Novelmates::App.helpers do
  def attending?
    return false if !signed_in?
    return false if meetups?
    @attendants.include? current_user._id
  end

  def notify?
    return false if !signed_in?
    m = Meetup.where(notify_ids: current_user._id, user_ids: current_user._id) 
    
    return false if m.all.entries == []
    return true
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
