require 'erb'
desc "Send out email notifications"
task :email_notifications => :environment do
  t = Time.now

  r = Time.local(t.year, t.month, t.day, 9)..Time.local(t.year, t.month, t.day, 16, 30)
  if r.cover? t #Time.now.friday? # previous answer: Date.today.wday == 5
    # first, let's read the template
    template = File.read("#{Padrino.root}/app/views/email.erb")
    
    # now, lets get the data the template needs
    # looks like a controller line, don't it?
    u = User.find_by(email: 'andres.tuul@gmail.com')
    @meetups = Meetup.where(user_ids: u._id).all.entries

    
    # let's render into a local 'result' string.
    # This is using the ERB class to create a new instance of a renderer from
    # our template.
    # it then calls result, passing in our current context so the template
    # can access our @person variable.  This is the most confusing part.
    renderer = ERB.new(template)
    result = renderer.result(binding)
    
    # Let's write the result out to a file for Charles.
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
      subject 'Check wanted to say Hello at ' + t.to_s
    end
    mail.html_part = html_part
    mail.deliver
  end
end