class Meetup
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,          type: String
  field :date,          type: String
  field :city,          type: String
  field :creator,       type: String
  field :participants,  type: String,   :default  => {}
  field :posts,         type: Hash,     :default  => {}
  field :venue,         type: Hash,     :default  => {}
  field :description,   type: String
  field :active,        type: Boolean,  :default  => true
  field :books,         type: Array

  embeds_many :posts
  has_and_belongs_to_many :users
  validates_presence_of     :name, :books, :city, :creator
end
