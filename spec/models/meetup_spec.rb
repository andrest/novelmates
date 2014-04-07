describe Meetup do
  before do
    @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
    @meetup = Meetup.create(name: "Testing meetups", location: 'London, United Kingdom', books: '0762448652')
    @venue = {name: 'Flat Iron', date: '2014-06-30 13:29:38 +0100', address: '5 Silver Place, London', notes: "Call Mary"}

    @meetup.update_attributes(venue: @venue, creator: @user._id, user_ids: [@user._id])
    @user.update_attributes(meetups_ids: [@meetup._id])
  end

  describe Venue do
    subject { @meetup.venue }
    it { should respond_to(:name) }
    it { should respond_to(:date) }
    it { should respond_to(:address) }
    it { should respond_to(:notes) }
  end

  subject { @meetup }

  it { should respond_to(:name) }
  it { should respond_to(:date) }
  it { should respond_to(:city) }
  it { should respond_to(:creator) }
  it { should respond_to(:notify_ids) }
  it { should respond_to(:description) }
  it { should respond_to(:books) }

end