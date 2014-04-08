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

  def send_notifications(meetup)
    meetup.notify_ids.each do |id|
      u = User.find(id)
      next if u.email.nil?
      template = File.read("#{Padrino.root}/app/views/notify-email.erb")

      @content = <<-eos
        Hello #{u.firstname},
        <br />
        <br />
        Just to let you know, #{current_user.firstname} #{current_user.lastname} just signed up for <em>#{meetup.name}</em>
        <br />
        <br />
        Novelmates
      eos
      renderer = ERB.new(template)
      result = renderer.result(binding)
      email_body = result

      html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body email_body
      end

      Mail.defaults do
        delivery_method :smtp, {
          :address => 'smtp.sendgrid.net',
          :port => '587',
          :domain => 'heroku.com',
          :user_name => ENV['SENDGRID_USERNAME'],
          :password => ENV['SENDGRID_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      end

      
       
      mail = Mail.new do
        to 'andres.tuul@gmail.com'
        from 'hello@novelmates.com'
        subject 'New attendant for '+meetup.name
      end
      mail.html_part = html_part
      mail.deliver
      return true
    end
  end
end
