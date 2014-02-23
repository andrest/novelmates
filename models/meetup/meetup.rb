class Meetup
  include Mongoid::Document
  include Mongoid::Timestamps
  # timestamps!
  
  # self.include_root_in_json = true
  
  field :name,       type: String
  field :date,        type: String
  field :city,           type: String
  field :participants,        type: String
  field :posts,           type: Hash,     :default => {}
  field :venue,        type: Hash,     :default => {}
  field :description,  type: String
  field :active,          type: Boolean,  :default => true
  
  attr_accessor :password
  
  validates_presence_of     :firstname, :lastname
  # validates_presence_of     :password #, :on => :create
  # validates_confirmation_of :password
  # Make sure email contains an @
  validates_format_of       :email, with: /@/
  validates_inclusion_of    :active, :in => [true, false]
  validates_uniqueness_of   :email,
                            :message => "User with this email already exists."
  # validates_uniqueness_of   :email
  # validates_format_of       :username,  :with => /\A[A-Za-z0-9_]+\z/, 
  #                                       :message => "must contain only letters, numbers and underscores."
  validates_format_of       :email, :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
                                        
  before_save               :_encrypt_password
  
  belongs_to  :account
  
  def self.authenticate(email, password)
    user = self.where(:email => email, :active => true).first
    p user
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end
  
  private
  
  def _encrypt_password
    if self.password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(self.password, self.password_salt)
    end
  end
end

class FB_Token
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  
  field :uid,          type: String
  field :expires_at,   type: Date
  field :token,        type: String
end