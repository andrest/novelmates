describe 'meetups listing' do 
  before(:each) do
    logout
  end
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
    page.should have_content 'Invalid login credentials'
  end

  # it 'should permit meetup creation' do
  #   visit '/'
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
  #   within('.meetup-header') { expect(page).to have_content('Test event123') }
  # end

  after(:all) do
    Warden.test_reset!
  end
end