# Some from examples by Michael Hartl
# https://github.com/railstutorial/sample_app_rails_4/blob/master/spec/models/user_spec.rb 
describe User do
  
  before do
    @user = User.create(firstname: "Rebane", lastname: "Ruben", :email => 'user@example.com', :password => 'pass')
    @meetup = Meetup.create(name: "Testing meetups", creator: @user._id, location: 'London, United Kingdom', books: '0762448652', user_ids: [@user._id])
    @user.meetup_ids << @meetup._id
    @user.save
  end
  subject { @user }
  it { should respond_to(:firstname) }
  it { should respond_to(:lastname) }
  it { should respond_to(:email) }
  it { should respond_to(:password_hash) }
  it { should respond_to(:password_salt) }
  it { should respond_to(:weekly_digest) }
  it { should respond_to(:meetups) }

  # it { should be_valid }

  describe "when name is not present" do
    before do
     @user.firstname = nil
     @user.lastname = nil
    end
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
      it "should be invalid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        addresses.each do |invalid_address|
          @user.email = invalid_address
          expect(@user).not_to be_valid
        end
      end
    end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end
end