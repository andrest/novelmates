require 'faker' 
FactoryGirl.define do 
  factory :user do 
    firstname { Faker::Name.first_name } 
    lastname { Faker::Name.last_name } 
    password = 'password'
    weekly_digest ='false'
    active = 'true'
    email { "#{firstname}.#{lastname}@novelmates.com".downcase }
    FBTokens { FactoryGirl.build(:FBToken) }
  end 

  factory :interest do
    sequence(:category)  { |n| "Interest category #{n}" }
    isbn = '0762448652'
    after(:create) do |interest|
      interest.users << FactoryGirl.build(:user)
    end
  end

  factory :venue do
    
  end

  factory :meetup do
    after(:create) do |meetup|
      meetup.users << FactoryGirl.build(:user)
    end
  end

  factory :FBToken do
    uid = "100000117098968" 
    token = "CAAIqlCw8Am8BADih4dWJjCSeCwgePl4GiThMUbSdyPJaIVyY4Dlkxfqq9ZB2ZBVXWkuZAZC5Rbx57yBZBHd92ujHiUZAAtmrflOu8zvQFZAO81E6RtjDpC3ZAZBBhE3p0eJIpwYRtclfNLwZAxCYSuC8a5vqYO46VeJqW1XBbTcoq8M6PKFnSXsITGYkSZAaoGz5UEZD"
  end

end