require 'spec_helper'
describe 'novelmates home page' do 
  it "should load the home page" do # the first test
    get '/' # you are visiting the home page
    last_response.should be_ok # it will true if the home page load successfully
  end
  it 'should load the mosaic for a city' do
    visit '/mosaic/2643743'
    page.should have_css '.book-link'
  end
  it 'should load the default mosaic' do
    visit '/mosaic'
    page.should have_css '.book-link'
  end
end

describe 'meetups listing' do 
  it 'should have a meetup' do
    visit '/meetups/at/2643743/for/0762448652/tequila-mockingbird'
    page.should have_content 'Tequila Mockingbird: Cocktails with a Literary Twist'
    page.should have_content 'Interest Categories'
    page.should have_content 'Tim Federle'
  end

  it 'should not permit meetup creation without login' do
    visit '/meetups/at/2643743/for/0762448652/tequila-mockingbird'
    page.should have_content 'Create new meetup'
    within('.new-meetup') { fill_in 'Event name', with: 'Test event123' }
    check 'notification'
    click_button 'Create'
    page.should have_content 'Something went wrong.'
  end

  it 'should permit meetup creation' do
    User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
    within("#sign-in") do
      fill_in 'E-mail', :with => 'user@example.com'
      fill_in 'Password', :with => 'pass'
    end
    click_button 'Submit'
    page.should have_selector('#log-out')

    page.should have_content 'Create new meetup'
    within('.new-meetup') { fill_in 'Event name', with: 'Test event123' }
    check 'notification'
    click_button 'Create'
    save_and_open_page
    within('.meetup-header') { expect(page).to have_content('Test event123') }
  end

  after(:all) do
    click_button 'Log out'
  end
end

describe "adding interest", :type => :controller do
  # it 'should not permit interest creation without login' do
  #   xhr :post, interest: { title: "foo", body: "bar" }
  #   response.code.should == "200"
    
  #   page.should have_content 'Something went wrong.'
  # end

  it "should respond with 401" do
    params = {
      isbn: '0762448652',
      interest: 'Test interest12345'
    }

    post '/book/interest', params

    last_response.should_not be_successful
  end

  it "should add interest", js: true do
    visit '/'
    User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
    within("#sign-in") do
      fill_in 'E-mail', :with => 'user@example.com'
      fill_in 'Password', :with => 'pass'
    end
    click_button 'Submit'
    page.should have_selector('#log-out')

    

    last_response.should be_successful

  end


  # it 'should permit interest creation' do
  #   User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
  #   within("#sign-in") do
  #     fill_in 'E-mail', :with => 'user@example.com'
  #     fill_in 'Password', :with => 'pass'
  #   end
  #   click_button 'Submit'
  #   page.should have_selector('#log-out')

  #   page.should have_content 'Create new meetup'
  #   within('.new-meetup') { fill_in 'Event name', with: 'Test event123' }
  #   check 'notification'
  #   click_button 'Create'
  #   save_and_open_page
  #   within('.meetup-header') { expect(page).to have_content('Test event123') }
  # end
end

# describe "the signin process", :type => :feature do
#   before :each do
#     User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#   end
#   it "invalid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => '1231231231232da'
#     end
#     click_button 'Submit'
#     page.should have_content 'Invalid login credentials'
#   end
#   it "valid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => 'pass'
#     end
#     click_button 'Submit'
#     page.should have_selector('#log-out')
#   end
# end

# # Some from examples by Michael Hartl
# # https://github.com/railstutorial/sample_app_rails_4/blob/master/spec/models/user_spec.rb 
# describe User do

#   before do
#     @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#     @meetup = Meetup.create(name: "Testing meetups", creator: @user._id, location: 'London, United Kingdom', books: '0762448652', user_ids: [@user._id])
#     @user.meetup_ids << @meetup._id
#     @user.save
#   end
#   subject { @user }
#   it { should respond_to(:firstname) }
#   it { should respond_to(:lastname) }
#   it { should respond_to(:email) }
#   it { should respond_to(:password_hash) }
#   it { should respond_to(:password_salt) }
#   it { should respond_to(:weekly_digest) }
#   it { should respond_to(:meetups) }

#   # it { should be_valid }

#   describe "when name is not present" do
#     before do
#      @user.firstname = nil
#      @user.lastname = nil
#     end
#     it { should_not be_valid }
#   end

#   describe "when email is not present" do
#     before { @user.email = " " }
#     it { should_not be_valid }
#   end

#   describe "when email format is invalid" do
#       it "should be invalid" do
#         addresses = %w[user@foo,com user_at_foo.org example.user@foo.
#                        foo@bar_baz.com foo@bar+baz.com foo@bar..com]
#         addresses.each do |invalid_address|
#           @user.email = invalid_address
#           expect(@user).not_to be_valid
#         end
#       end
#     end

#   describe "when email format is valid" do
#     it "should be valid" do
#       addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
#       addresses.each do |valid_address|
#         @user.email = valid_address
#         expect(@user).to be_valid
#       end
#     end
#   end

#   describe "when email address is already taken" do
#     before do
#       user_with_same_email = @user.dup
#       user_with_same_email.email = @user.email.upcase
#       user_with_same_email.save
#     end

#     it { should_not be_valid }
#   end
# end

# describe Meetup do
#   before do
#     @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#     @meetup = Meetup.create(name: "Testing meetups", location: 'London, United Kingdom', books: '0762448652')
#     @venue = {name: 'Flat Iron', date: '2014-06-30 13:29:38 +0100', address: '5 Silver Place, London', notes: "Call Mary"}

#     @meetup.update_attributes(venue: @venue, creator: @user._id, user_ids: [@user._id])
#     @user.update_attributes(meetups_ids: [@meetup._id])
#   end

#   describe Venue do
#     subject { @meetup.venue }
#     it { should respond_to(:name) }
#     it { should respond_to(:date) }
#     it { should respond_to(:address) }
#     it { should respond_to(:notes) }
#   end

#   subject { @meetup }

#   it { should respond_to(:name) }
#   it { should respond_to(:date) }
#   it { should respond_to(:city) }
#   it { should respond_to(:creator) }
#   it { should respond_to(:notify_ids) }
#   it { should respond_to(:description) }
#   it { should respond_to(:books) }

# end

# describe Interest do
#   before do
#     @FBToken = FBToken.new(uid: "100000117098968", token: "CAAIqlCw8Am8BADih4dWJjCSeCwgePl4GiThMUbSdyPJaIVyY4Dlkxfqq9ZB2ZBVXWkuZAZC5Rbx57yBZBHd92ujHiUZAAtmrflOu8zvQFZAO81E6RtjDpC3ZAZBBhE3p0eJIpwYRtclfNLwZAxCYSuC8a5vqYO46VeJqW1XBbTcoq8M6PKFnSXsITGYkSZAaoGz5UEZD")
#     @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#     @meetup = Meetup.create(name: "Testing meetups", location: 'London, United Kingdom', books: '0762448652')
#     @venue = {name: 'Flat Iron', date: '2014-06-30 13:29:38 +0100', address: '5 Silver Place, London', notes: "Call Mary"}
#     @interest = Interest.create(isbn: '0762448652', category: 'Author discussion for testing')

#     @meetup.update_attributes(venue: @venue, creator: @user._id, user_ids: [@user._id])
#     @user.update_attributes(FBTokens: @FBToken, meetups_ids: [@meetup._id], interest_ids: [@interest])
#     @interest.update_attributes(user_ids: [@user._id])
#   end
#   it { should respond_to(:isbn) }
#   it { should respond_to(:category) }
# end

# describe FBToken do
#   before do
#     @FBToken = FBToken.new(uid: "100000117098968", token: "CAAIqlCw8Am8BADih4dWJjCSeCwgePl4GiThMUbSdyPJaIVyY4Dlkxfqq9ZB2ZBVXWkuZAZC5Rbx57yBZBHd92ujHiUZAAtmrflOu8zvQFZAO81E6RtjDpC3ZAZBBhE3p0eJIpwYRtclfNLwZAxCYSuC8a5vqYO46VeJqW1XBbTcoq8M6PKFnSXsITGYkSZAaoGz5UEZD")
#     @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#     @meetup = Meetup.create(name: "Testing meetups", location: 'London, United Kingdom', books: '0762448652')
#     @venue = {name: 'Flat Iron', date: '2014-06-30 13:29:38 +0100', address: '5 Silver Place, London', notes: "Call Mary"}
#     @interest = Interest.create(isbn: '0762448652', category: 'Author discussion for testing')

#     @meetup.update_attributes(venue: @venue, creator: @user._id, user_ids: [@user._id])
#     @user.update_attributes(FBTokens: @FBToken, meetups_ids: [@meetup._id], interest_ids: [@interest])
#     @interest.update_attributes(user_ids: [@user._id])
#   end
   
#   it { should respond_to(:uid) }
#   it { should respond_to(:expires_at) }
#   it { should respond_to(:token) }
# end








# describe 'interests'

# describe "the mosaic", :type => :feature do
#   before :each do
#     User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#   end
#   it "invalid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => '1231231231232da'
#     end
#     click_button 'Submit'
#     page.should have_content 'Invalid login credentials'
#   end
#   it "valid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => 'pass'
#     end
#     click_button 'Submit'
#     page.should have_selector('#log-out')
#   end
# end

# describe "searching meetups", :type => :feature do
#   before :each do
#     User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
#   end
#   it "invalid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => '1231231231232da'
#     end
#     click_button 'Submit'
#     page.should have_content 'Invalid login credentials'
#   end
#   it "valid sign in" do
#     visit '/'
#     within("#sign-in") do
#       fill_in 'E-mail', :with => 'user@example.com'
#       fill_in 'Password', :with => 'pass'
#     end
#     click_button 'Submit'
#     page.should have_selector('#log-out')
#   end
# end

# describe "meetup", :type => :feature do

#   it "find meetup"
#   it "add interest"
#   it "create interest"
#   it "create meetup" do

#   end
#   it "attend meetup" do

#   end
# end

# describe "user", :type => :feature do

#   it "has profile"
#   it "has profile pic"
#   it "has details"
#   it "has notifications"
# end