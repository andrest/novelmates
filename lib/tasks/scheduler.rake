desc "Send out email notifications"
task :email_notifications => :environment do
  t = Time.now

  r = Time.local(t.year, t.month, t.day, 9)..Time.local(t.year, t.month, t.day, 16, 30)
  if r.cover? t #Time.now.friday? # previous answer: Date.today.wday == 5
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


    u = User.find_by(email: 'andres.tuul@gmail.com')
    @meetups = Meetup.in(user_ids: ['5333014e2cf31089e7000001']).all.entries
    email_body = erb :email
     
    Mail.deliver do
      to 'andres.tuul@gmail.com'
      from 'hello@novelmates.com'
      subject 'Just wanted to say Hello at ' + t.to_s
      body ERB.new(File.read('views/email.erb')).result(context)
    end
  end
end