require 'spec_helper'

describe "meetups_controller", :type => :controller do
  describe "create" do
    before(:each) { logout }

    describe "should fail" do
      it 'if not logged in' do
        @jack = create(:jack)
        params = {
          name: 'Test Auto',
          city: '2643743',
          notification: 'false',
          books: '0679735771',
          creator: @jack._id
        }

        post '/meetup/create', params
        last_response.should_not be_successful
      end

      it 'if no :name' do
        @jack = create(:jack)
        login_as(@jack)
        params = {
          city: '2643743',
          notification: 'false',
          books: '0679735771',
          creator: @jack._id
        }

        post '/meetup/create', params
        last_response.should_not be_successful
      end

      it 'if no :books' do
        @jack = create(:jack)
        login_as(@jack)
        params = {
          name: 'Test Auto',
          city: '2643743',
          notification: 'false',
          creator: @jack._id
        }

        post '/meetup/create', params
        last_response.should_not be_successful
      end

      it 'if no :city' do
        @jack = create(:jack)
        login_as(@jack)
        params = {
          name: 'Test Auto',
          notification: 'false',
          books: '0679735771',
          creator: @jack._id
        }

        post '/meetup/create', params
        last_response.should_not be_successful
      end

      it 'if no :creator' do
        @jack = create(:jack)
        login_as(@jack)
        params = {
          creator: @jack._id
        }

        post '/meetup/create', params
        last_response.should_not be_successful
      end
    end

    it "should succeed" do
      @jack = create(:jack)
      login_as(@jack)

      params = {
        name: 'Test Auto',
        city: '2643743',
        notification: 'false',
        books: '0679735771',
        creator: @jack._id
      }

      post '/meetup/create', params
      last_response.status.should eql(302) 
    end

  end

  describe "update" do
    before(:each) { logout }

    describe "should fail" do
      it 'if not logged in' do
        @jack = create(:jack)
        @meet = @jack.meetups[0]
        params = {
          name: 'Test Update with new Name',
          city: @meet.city,
          books: @meet.books,
          user_id: @jack._id,
          id: @meet._id
        }

        post '/meetup/update', params
        last_response.should_not be_successful
      end

      it 'if wrong user id' do
        @jack = create(:jack)
        @meet = @jack.meetups[0]
        login_as(@jack)
        params = {
          name: 'Test Update with new Name',
          # date
          city: @meet.city,
          # description
          books: @meet.books,
          user_id: create(:user)._id,
          id: @meet._id,
          # venue: {name:"", address:"", notes:"asd"}
        }

        post '/meetup/update', params
        last_response.should_not be_successful
      end
    end

    it "should succeed" do
      @jack = create(:jack)
      @meet = @jack.meetups[0]
      login_as(@jack)
      params = {
        name: 'Test Update with new Name',
        city: @meet.city,
        books: @meet.books,
        user_id: @jack._id,
        id: @meet._id
      }

      post '/meetup/update', params
      last_response.status.should eql(302) 
    end

  end

  describe "notify" do
    before(:each) { logout }

    describe "should fail" do
      it 'if user not signed in' do
        @jack = create(:jack)
        @meet = @jack.meetups[0]
        params = {
          meetup_id: @meet._id,
          notify: 'true'
        }

        post '/meetup/notify', params
        last_response.should_not be_successful
      end
    end

    it "should succeed" do
      @jack = create(:jack)
      @meet = @jack.meetups[0]
      login_as(@jack)
      params = {
        meetup_id: @meet._id,
        notify: 'true'
      }

      post '/meetup/notify', params
      last_response.should be_successful
    end

  end

  describe "attend" do
    before(:each) { logout }

    describe "should fail" do
      it 'if not logged in' do
        @jack = create(:jack)
        @meet = @jack.meetups[0]
        params = {
          meetup_id: @meet._id,
          attending: 'false'
        }

        post '/meetup/attending', params
        last_response.should_not be_successful
      end
    end

    it "should succeed" do
        @jack = create(:jack)
        @meet = @jack.meetups[0]
        login_as(@jack)
        params = {
          meetup_id: @meet._id,
          attending: 'false'
        }

      post '/meetup/attending', params
      last_response.status.should eql(200) 
    end

  end
end