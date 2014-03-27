desc "Send out email notifications"
task :email_notifications => :environment do
  t = Time.now

  r = Time.local(t.year, t.month, t.day, 9).to_i..Time.local(t.year, t.month, t.day, 16, 30).to_i
  if r === t #Time.now.friday? # previous answer: Date.today.wday == 5
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

    Mail.deliver do
      to 'andres.tuul@gmail.com'
      from 'hello@novelmates.com'
      subject 'Just wanted to say Hello at ' + t.to_s
      body 'Sending email with Ruby through SendGrid!'
    end
  end
end