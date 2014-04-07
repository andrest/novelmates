require 'spec_helper'

describe "book_controller", :type => :controller do
  it "should get book" do
    get '/get_book/0762448652'
    last_response.should be_successful
  end

  describe "interest" do

    describe "add" do
      it "should respond with 401" do
        params = {
          isbn: '0762448652',
          interest: 'Test interest12345'
        }

        post '/book/interest', params
        last_response.should_not be_successful
      end

      it "should succeed" do
        u = create(:user)
        login_as u

        params = {
          isbn: '0762448652',
          interest: 'Test interest12345'
        }

        post '/book/interest', params
        last_response.should be_successful
      end
    end

    describe "remove" do
      it "should fail" do
        params = {
          isbn: '0762448652',
          interest: 'Test interest12345'
        }

        delete '/book/interest', params
        last_response.should_not be_successful
      end

      it "should succeed" do
        u = create(:user)
        login_as u

        params = {
          isbn: '0762448652',
          interest: 'Test interest12345'
        }

        delete '/book/interest', params
        last_response.should be_successful
      end
    end
  end


  after(:all) do
    Warden.test_reset!
  end
end