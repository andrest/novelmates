require 'spec_helper'
# describe 'novelmates home page' do 
#   it "should load the home page" do # the first test
#     get '/' # you are visiting the home page
#     last_response.should be_ok # it will true if the home page load successfully
#   end
#   it 'should load the mosaic for a city' do
#     visit '/mosaic/2643743'
#     page.should have_css '.book-link'
#   end
#   it 'should load the default mosaic' do
#     visit '/mosaic'
#     page.should have_css '.book-link'
#   end
# end

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

#   after(:all) do
#     Warden.test_reset!
#   end
# end

def sign_in()
  user = create(:jack)
  visit '/'
  click_button('Log in')
  page.save_screenshot('tmp/sign_in.png', :full => false)


    fill_in 'E-mail', :with => user.email
    fill_in 'Password', :with => 'jack'

  click_button 'Submit'
  page.should have_selector('#log-out')
  return user
end

# describe "the mosaic", :js => true do
#   it "should have the mosaic links" do
#     visit '/'
#     page.should have_css('.book-link')
#   end
# end

# describe "searching meetups", :js => true do
#   it "search books should bring up a dropdown" do
#     visit '/'
#     page.should have_css('#token-input-book-input')
    
#     fill_in 'token-input-book-input', with: 'harry'

#     page.execute_script %Q{ $('#token-input-book-input').trigger('focus') }
#     page.execute_script %Q{ $('#token-input-book-input').val('harry') }
#     page.execute_script %Q{ $('#token-input-book-input').trigger('keydown') }
#     # page.execute_script %Q{var e = jQuery.Event("keydown");
#     # e.which = 50; // # Some key code value
#     # $("#token-input-book-input").trigger(e); }

#     # page.save_screenshot('tmp/testshot.png', :full => false)

#     page.should have_content('Goblet Of Fire')
#     page.should have_content('Phoenix')
#     page.should have_content('Azkaban')
#   end

#   it "search books should bring up a dropdown" do
#     visit '/'
#     page.should have_css('#token-input-book-input')
    
#     fill_in 'token-input-book-input', with: 'harry'

#     page.execute_script %Q{ $('#token-input-book-input').trigger('focus') }
#     page.execute_script %Q{ $('#token-input-book-input').val('harry') }
#     page.execute_script %Q{ $('#token-input-book-input').trigger('keydown') }
#     # page.execute_script %Q{var e = jQuery.Event("keydown");
#     # e.which = 50; // # Some key code value
#     # $("#token-input-book-input").trigger(e); }

#     # page.save_screenshot('tmp/testshot.png', :full => false)

#     page.should have_content('Goblet Of Fire')
#     page.should have_content('Phoenix')
#     page.should have_content('Azkaban')
#   end
#   it "get first harry" do
#     first_harry()
#     page.save_screenshot('tmp/testshot.png', :full => false)
#     page.should have_content('Interest Categories')
#     page.should have_content('Meetups')
#     page.should have_css('.book-listing')
#   end

# end


def first_harry(field = 'token-input-book-input', options = {})
  # fill_in field, with: options[:with]
  visit '/'
  page.save_screenshot('tmp/beforeclick.png', :full => false)
  page.should have_css("##{field}")
  page.execute_script %Q{ $('##{field}').trigger('focus') }
  page.execute_script %Q{ $('##{field}').trigger('keydown') }
  page.execute_script %Q{ $('##{field}').val('harry') }

  # selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
  # $('.token-input-dropdown.book-input')

  page.should have_selector('.token-input-dropdown.book-input a')
  first(".token-input-dropdown.book-input li").click
  page.save_screenshot('tmp/afterclick.png', :full => false)
  # page.execute_script %Q{ $('.token-input-dropdown.book-input li:first').mousedown(function(){return true;}).mousedown() }
  
  # page.execute_script %Q{ $('.token-input-dropdown.book-input a:first').click(function(){return true;}).click() }
  # page.execute_script %Q{var e = jQuery.Event("keydown");
  # e.keyCode = 'KEY.ENTER'; // # Press enter
  # $('##{field}').trigger(e); }
  
  # page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
end

# def first_harry
#   page.execute_script %Q{ $('#token-input-book-input').trigger('focus') }
#   page.execute_script %Q{ $('#token-input-book-input').val('harry') }
#   page.execute_script %Q{ $('#token-input-book-input').trigger('keydown') }
# end
describe 'Meet-ups', :type => :feature,  js: 'true' do
  before(:all) do
    Warden.test_reset!
  end

  # it 'A registered user should be able to create a new meet-up for' do
  #   @jack = create(:jack)
  #   sign_in()
  #   first_harry()
  #   click_button 'Add new meetup'
  #   within '.new-meetup' do
  #     fill_in 'Event name', with: 'Capybara event'
  #     click_button 'Create'
  #   end
    
  #   within 'ol.breadcrumb' do 
  #     page.should have_content('Capybara event')
  #   end
  #   page.save_screenshot('tmp/create-meetup.png')
  # end 
  it 'The meet-up creator should be able to update existing meet-up details and pick a venue.' do
    @jack = create(:jack)
    sign_in()
    first_harry()
    click_button 'Add new meetup'
    within '.new-meetup' do
      fill_in 'Event name', with: 'Capybara event'
      click_button 'Create'
    end
    
    within 'ol.breadcrumb' do 
      page.should have_content('Capybara event')
    end

    first('.edit-meetup').click
    fill_in 'description', with: 'Capybara description'
    fill_in 'venue-name', with: "Prime Ministers Office"
    fill_in 'Address', with: "10 Downing St, London, UK"
    click_button 'Save'

    page.save_screenshot('tmp/edit-meetup.png')
  end
  it 'Any user should be able to view any meet-up details' do

  end
  it 'A registered user should be able to visibly attend a meet-up' do

  end
  it 'A registered user should be able to update her attending status' do

  end
  it 'The meet-up page should permit communication between the attendees' do

  end
end
describe 'Users' do
  it 'A non registered user should be able to sign up with the website using Facebook' do

  end
  it 'A non registered user should be able to sign up with the website using email' do

  end
  it 'A user should be able to edit the registration details after the account has been created' do

  end
  it 'Every user should have a public profile with the meet-ups he/she has attended' do

  end
end
describe 'Search' do
  it 'Books should be searchable by title' do

  end
  it 'User can input multiple locations' do

  end
end
describe 'Interest Categories' do
  it 'The user should be able to create new interest category' do

  end
  it 'The user should be able to vote on an existing interest category' do

  end
  it 'The user should be able to change its interests at any time' do

  end
end
describe 'Optional' do
  it 'The user should be able to search for multiple books at a time' do

  end
  it 'The user should be able to invite facebook friends to attend' do

  end
  it 'The application should try to determine user\'s location automatically' do

  end
end








describe "meetup", :type => :feature do

  it "find meetup"
  it "add interest"
  it "create interest"
  it "create meetup" do

  end
  it "attend meetup" do

  end
end

describe "user", :type => :feature do

  it "has profile"
  it "has profile pic"
  it "has details"
  it "has notifications"
end