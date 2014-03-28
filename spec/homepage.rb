require 'spec_helper'
describe 'novelmates home page' do 
  it "should load the home page" do # the first test
    get '/' # you are visiting the home page
    last_response.should be_ok # it will true if the home page load successfully
  end
end

describe "the signin process", :type => :feature do
  before :each do
    User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
  end

  it "signs me in" do
    visit '/'
    within("#sign-in") do
      fill_in 'E-mail', :with => 'user@example.com'
      fill_in 'Password', :with => 'pass'
    end
    click_button 'Submit'
    page.should have_selector('#log-out')

  end

end