class Meetup
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,          type: String
  field :date,          type: String
  field :city,          type: String
  field :participants,  type: String,   :default  => {}
  field :posts,         type: Hash,     :default  => {}
  field :venue,         type: Hash,     :default  => {}
  field :description,   type: String
  field :active,        type: Boolean,  :default  => true
  
  embeds_many :posts
end
