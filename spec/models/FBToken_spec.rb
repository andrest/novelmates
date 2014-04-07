require 'spec_helper'

describe "FBToken" do
  before do
    @FBToken = FBToken.new(uid: "100000117098968", token: "CAAIqlCw8Am8BADih4dWJjCSeCwgePl4GiThMUbSdyPJaIVyY4Dlkxfqq9ZB2ZBVXWkuZAZC5Rbx57yBZBHd92ujHiUZAAtmrflOu8zvQFZAO81E6RtjDpC3ZAZBBhE3p0eJIpwYRtclfNLwZAxCYSuC8a5vqYO46VeJqW1XBbTcoq8M6PKFnSXsITGYkSZAaoGz5UEZD")
    @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
    @meetup = Meetup.create(name: "Testing meetups", location: 'London, United Kingdom', books: '0762448652')
    @venue = {name: 'Flat Iron', date: '2014-06-30 13:29:38 +0100', address: '5 Silver Place, London', notes: "Call Mary"}
    @interest = Interest.create(isbn: '0762448652', category: 'Author discussion for testing')

    @meetup.update_attributes(venue: @venue, creator: @user._id, user_ids: [@user._id])
    @user.update_attributes(FBTokens: @FBToken, meetups_ids: [@meetup._id], interest_ids: [@interest])
    @interest.update_attributes(user_ids: [@user._id])
  end
  subject{ @FBToken }
  it { should respond_to(:uid) }
  it { should respond_to(:expires_at) }
  it { should respond_to(:token) }
end