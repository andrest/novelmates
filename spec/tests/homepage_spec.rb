require 'spec_helper'
require 'faker' 

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

describe "the signin process", :type => :feature do
  before :each do
    User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
  end
  it "invalid sign in" do
    visit '/'
    within("#sign-in") do
      fill_in 'E-mail', :with => 'user@example.com'
      fill_in 'Password', :with => '1231231231232da'
    end
    click_button 'Submit'
    page.should have_content 'Invalid login credentials'
  end
  it "valid sign in" do
    visit '/'
    within("#sign-in") do
      fill_in 'E-mail', :with => 'user@example.com'
      fill_in 'Password', :with => 'pass'
    end
    click_button 'Submit'
    page.should have_selector('#log-out')
  end

  after(:all) do
    Warden.test_reset!
  end
end

def sign_in()
  user = create(:jack)
  visit '/'
  click_button('Log in')

  # within '.login.dropdown' do
    fill_in 'E-mail', :with => user.email
    fill_in 'Password', :with => 'jack'
  # end
  click_button 'Submit'
  page.should have_selector('#log-out')
  return user
end

describe "the mosaic", :js => true do
  it "should have the mosaic links" do
    visit '/'
    page.should have_css('.book-link')
  end
end

describe "when searching meetups", :js => true do
  it "search books should bring up a dropdown" do
    visit '/'
    page.should have_css('#token-input-book-input')
    
    fill_in 'token-input-book-input', with: 'harry'

    page.execute_script %Q{ $('#token-input-book-input').trigger('focus') }
    page.execute_script %Q{ $('#token-input-book-input').val('harry') }
    page.execute_script %Q{ $('#token-input-book-input').trigger('keydown') }
    # page.execute_script %Q{var e = jQuery.Event("keydown");
    # e.which = 50; // # Some key code value
    # $("#token-input-book-input").trigger(e); }

    # page.save_screenshot('tmp/testshot.png', :full => false)

    page.should have_content('Goblet Of Fire')
    page.should have_content('Phoenix')
    page.should have_content('Azkaban')
  end

  it "books search should bring up a dropdown" do
    visit '/'
    page.should have_css('#token-input-book-input')
    
    fill_in 'token-input-book-input', with: 'harry'

    page.execute_script %Q{ $('#token-input-book-input').trigger('focus') }
    page.execute_script %Q{ $('#token-input-book-input').val('harry') }
    page.execute_script %Q{ $('#token-input-book-input').trigger('keydown') }

    page.should have_content('Goblet Of Fire')
    page.should have_content('Phoenix')
    page.should have_content('Azkaban')
  end
  it "get first harry" do
    first_harry()
    page.should have_content('Interest Categories')
    page.should have_content('Meetups')
    page.should have_css('.book-listing')
  end

end


def first_harry(field = 'token-input-book-input', options = {})
  # fill_in field, with: options[:with]
  visit '/'
  page.should have_css("##{field}")
  page.execute_script %Q{ $('##{field}').trigger('focus') }
  page.execute_script %Q{ $('##{field}').trigger('keydown') }
  page.execute_script %Q{ $('##{field}').val('harry') }

  # selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
  # $('.token-input-dropdown.book-input')

  page.should have_selector('.token-input-dropdown.book-input a')
  first(".token-input-dropdown.book-input li").click
  # page.execute_script %Q{ $('.token-input-dropdown.book-input li:first').mousedown(function(){return true;}).mousedown() }
  
  # page.execute_script %Q{ $('.token-input-dropdown.book-input a:first').click(function(){return true;}).click() }
  # page.execute_script %Q{var e = jQuery.Event("keydown");
  # e.keyCode = 'KEY.ENTER'; // # Press enter
  # $('##{field}').trigger(e); }
  
  # page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
end

def add_city(city = "Oxford, United")
  field = 'token-input-city-input'
  # fill_in field, with: options[:with]
  visit '/'
  page.should have_css("##{field}")
  page.execute_script %Q{ $('#token-input-city-input').trigger('focus') }
  page.execute_script %Q{ $('#token-input-city-input').val('#{city}') }
  page.execute_script %Q{ $('#token-input-city-input').trigger('keydown') }
  # selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{options[:select]}")}
  # $('.token-input-dropdown.book-input')

  page.should have_selector('.token-input-dropdown.city-input li')
  first(".token-input-dropdown.city-input li").click

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

describe '1. Meet-ups', :type => :feature,  js: 'true' do
  before(:all) do
    Warden.test_reset!
    Capybara.reset_session!
  end
  before(:each) do
    @jack = create(:jack)
    sign_in()
    first_harry()
  end

  it '1a A registered user should be able to create a new meet-up' do

    click_button 'Add new meetup'
    within '.new-meetup' do
      fill_in 'Event name', with: 'Capybara event'
      click_button 'Create'
    end
    
    within 'ol.breadcrumb' do 
      page.should have_content('Capybara event')
    end
  end 
  it '1b The meet-up creator should be able to update existing meet-up details and pick a venue.' do

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
  end
  it '1c Any user should be able to view any meet-up details' do
    click_button 'Add new meetup'
    within '.new-meetup' do
      fill_in 'Event name', with: 'Capybara event'
      click_button 'Create'
    end

    page.should have_css('.meetup-info')
  end
  it '1d A registered user should be able to visibly attend a meet-up' do
    click_button 'Add new meetup'
    within '.new-meetup' do
      fill_in 'Event name', with: 'Capybara event'
      click_button 'Create'
    end
    click_button 'Attending'
    within '.meetup-info' do
      page.should have_selector('.user_card')
      page.should have_content('Jack Black')
    end
  end
  it '1e A registered user should be able to update her attending status'
  it '1f The meet-up page should permit communication between the attendees' do
    click_button 'Add new meetup'
    within '.new-meetup' do
      fill_in 'Event name', with: 'Capybara event'
      click_button 'Create'
    end
    within '.juvia-textarea-field' do
      fill_in 'content', with: 'test comment'
    end
    click_button 'Submit'
    page.should have_content('test comment')
  end
end
describe 'Users', :type => :feature,  js: 'true' do
  before(:all) do
    Warden.test_reset!
    Capybara.reset_session!
  end
  it '2a A non registered user should be able to sign up with the website using Facebook'

  it '2b A non registered user should be able to sign up with the website using email' do
    # visit '/'
    # first = Faker::Name.first_name
    # last  = Faker::Name.last_name 

    # within '#wrapper' do
    #   fill_in 'E-mail', with: first+last+ '@fake.com'
    #   fill_in 'First name', with: 'fake'
    #   fill_in 'Last name', with: 'fake'
    #   fill_in 'passwd', with: 'fake'
    #   click_button "Register with E-mail"
    # end
    
    # # page.save_screenshot('tmp/debug.png', :full => false)
    # save_and_open_page
    # within '.profile-pic' do
    #   page.should have_content(first[0]+last[0])
    # end
  end
  it '2c A user should be able to edit the registration details after the account has been created' do
    @jack = create(:jack)
    sign_in()
    visit '/user/edit'
    fill_in 'First name', with:'NewName'
    click_button 'Save'
    page.status_code.should be 200

  end
  it '2d Every user should have a public profile with the meet-ups he/she has attended'
end
describe 'Search', :type => :feature,  js: 'true'  do
  it '3a Books should be searchable by title' do
    # Validated before
  end
  it '3b User can input multiple locations' do
    visit '/'
    add_city("Oxford, United")
    # add_city("Manchester, United")
    # first('.book-link').click()
    within '.city-search' do
      page.all(".token-input-token").count.should eql(2)
    end
  end
end
describe 'Interest Categories', :type => :feature,  js: 'true'  do
  before(:all) do
    Warden.test_reset!
    Capybara.reset_session!
  end
  it '4a The user should be able to create new interest category' do
    @jack = create(:jack)
    sign_in()
    first('.book-link').click()
    # fill_in 'Add new..', with: 'new interest'
    within "#interest-categories .list-group-item:last-child" do
      fill_in 'name', with: 'new interest123'
      find('.add-interest').click
    end
      within "#interest-categories .list-group-item:nth-last-child(2)" do
        page.should have_content('new interest123')
        page.should have_selector(".remove-interest", text: "JB", :visible => true)
      end
    # find("#interest-categories .list-group-item:nth-last-child(2)").should have_content('new interest123')
  end
  it '4b The user should be able to vote on an existing interest category' do
    @jack = create(:jack)
    sign_in()
    first('.book-link').click()
    page.should have_css("#interest-categories .list-group-item")
    within "#interest-categories .list-group-item:first-child" do
      page.should have_selector(".remove-interest.hidden", text: "JB", :visible => false)
      find(".add-interest").click
      page.should have_selector(".add-interest.hidden", :visible => false)
    end
  end
  it '4c The user should be able to change its interests at any time' do
    @jack = create(:jack)
    sign_in()
    first('.book-link').click()
    # fill_in 'Add new..', with: 'new interest'
    within "#interest-categories .list-group-item:last-child" do
      fill_in 'name', with: 'add/remove interest567'
      find('.add-interest').click
    end
    within "#interest-categories .list-group-item:nth-last-child(2)" do
      page.should have_content('add/remove interest567')
      page.should have_selector(".remove-interest", text: "JB", :visible => true)
      find('.remove-interest').click
      # page.driver.debug
      page.should have_selector(".remove-interest.hidden", text: "JB", :visible => false)
    end
    # save_and_open_page
    # page.should have_css("#interest-categories .list-group-item:nth-last-child(2) .remove-interest.hidden")
  end
end