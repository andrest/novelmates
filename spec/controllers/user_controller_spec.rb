require 'spec_helper'

describe "user_controller", :type => :controller do
  it "get profile pic" do
    @jack = create(:jack)

    get "/user/#{@jack._id}/profile_pic"
    last_response.should be_successful
  end

  describe "get /user/profile" do
    it "should fail if not signed in" do
      get "/user/profile"
      last_response.should_not be_successful
    end

    it "should succeed" do
      @user = create(:user)
      login_as @user
      get "/user/profile"
      last_response.should be_successful
    end
  end

  describe "get /user/edit" do
    it "should fail if not signed in" do
      get "/user/edit"
      last_response.should_not be_successful
    end

    it "should succeed" do
      @jack = create(:jack)
      login_as @jack
      get "/user/edit"
      last_response.should be_successful
    end
  end

  describe "get /user/:id" do
    it "should fail if user not exists" do
      get "/user/0"
      last_response.should_not be_successful
    end

    it "should succeed if user exists" do
      @user = create(:user)
      get "/user/#{@user._id}"
      last_response.should be_successful
    end
  end
end