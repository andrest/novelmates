class FBToken
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user
  
  field :uid,          type: String
  field :expires_at,   type: Date
  field :token,        type: String
end

class Interest
  include Mongoid::Document
  field :isbn,          type: String
  field :category,      type: String
  has_and_belongs_to_many :users
end

# class Books
#   include Mongoid::Document
#   include Mongoid::Timestamps
#   # embedded_in :user
#   embeds_many :interests
#   accepts_nested_attributes_for :interests

#   field :isbn,          type: String

# end


class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # timestamps!
  
  # self.include_root_in_json = true
  embeds_one :FBTokens
  has_and_belongs_to_many :interests
  has_and_belongs_to_many :meetups

  # field :username,        type: String,   :default => UUID::generate(:compact)
  field :password_hash,   type: String
  field :password_salt,   type: String
  field :firstname,       type: String,   :default => 'John'
  field :lastname,        type: String,   :default => 'Doe'
  field :email,           type: String
  field :timezone,        type: String
  # field :oauth,           type: Hash,     :default => {}
  field :location,        type: String
  field :active,          type: Boolean,  :default => true
  field :profile,         type: String
  
  attr_accessor :password
  
  validates_presence_of     :firstname, :lastname
  # validates_presence_of     :password #, :on => :create
  # validates_confirmation_of :password
  # Make sure email contains an @
  validates_format_of       :email, with: /@/
  validates_inclusion_of    :active, :in => [true, false]
  # validates_uniqueness_of   :email,
                            # :message => "User with this email already exists."
  # validates_uniqueness_of   :email
  # validates_format_of       :username,  :with => /\A[A-Za-z0-9_]+\z/, 
  #                                       :message => "must contain only letters, numbers and underscores."
  validates_format_of       :email, :with => /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/
                                        
  before_save               :_encrypt_password
  before_create             :_encrypt_password
  # def get_pic()
  #   if !self.profile.present?
  #     profi
  # end

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
