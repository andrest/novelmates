require 'faker' 
FactoryGirl.define do 
  saved_single_instances = {}
  #Find or create the model instance
  single_instances = lambda do |factory_key|
    begin
      saved_single_instances[factory_key].reload
    rescue NoMethodError, ActiveRecord::RecordNotFound  
      #was never created (is nil) or was cleared from db
      saved_single_instances[factory_key] = Factory.create(factory_key)  #recreate
    end

    return saved_single_instances[factory_key]
  end

  factory :jack, :class => User do 
    initialize_with { User.find_or_create_by(:email => email)}

    firstname "Jack" 
    lastname "Black" 
    email "jack@black.com" 
    password "jack" 
    active "true" 
    weekly_digest 'false'

    after(:create) do |u|
      u.interests = [FactoryGirl.build(:interest), FactoryGirl.build(:interest)]
      u.meetups = [FactoryGirl.create(:meetup_with_venue, creator: u._id)]
    end
  end

  factory :user do 
    firstname { Faker::Name.first_name } 
    lastname { Faker::Name.last_name } 
    password = 'password'
    weekly_digest ='false'
    active = 'true'
    email { "#{firstname}.#{lastname}@novelmates.com".downcase }
  end

  factory :user2 do 
    firstname { Faker::Name.first_name } 
    lastname { Faker::Name.last_name } 
    password = 'password'
    weekly_digest ='false'
    active = 'true'
    email { "#{firstname}.#{lastname}@novelmates.com".downcase }
  end 
 

  factory :fb_user do 
    firstname { Faker::Name.first_name } 
    lastname { Faker::Name.last_name } 
    password = '',
    weekly_digest ='false'
    active = 'true'
    email { "#{firstname}.#{lastname}@novelmates.com".downcase }
    FBTokens { FactoryGirl.build(:FBToken) }
  end 

  factory :interest do
    sequence(:category)  { |n| "Interest category #{n}" }
    isbn = '0762448652'
    # after(:create) do |interest|
    #   interest.users << FactoryGirl.build(:user)
    # end
  end

  factory :venue do
    name "Monmouth Coffee"
    address 'Monmouth Coffee, Covent Garden, London'
    notes 'Reservation for "Mary"'
  end

  factory :meetup do
    name 'Lets talk business'
    city '2643743'
    # creator u1._id
    books '0762448652'

    factory :meetup_with_venue do
      after(:create) do |m|
        m.venue FactoryGirl.build(:venue)
      end
    end
    # after(:create) do |meetup|
    #   meetup.users << FactoryGirl.build(:user)
    # end
  end

  factory :FBToken do
    uid = "100000117098968" 
    token = "CAAIqlCw8Am8BADih4dWJjCSeCwgePl4GiThMUbSdyPJaIVyY4Dlkxfqq9ZB2ZBVXWkuZAZC5Rbx57yBZBHd92ujHiUZAAtmrflOu8zvQFZAO81E6RtjDpC3ZAZBBhE3p0eJIpwYRtclfNLwZAxCYSuC8a5vqYO46VeJqW1XBbTcoq8M6PKFnSXsITGYkSZAaoGz5UEZD"
  end

end