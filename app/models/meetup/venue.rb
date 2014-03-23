class Venue
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,          type: String
  field :date,          type: DateTime
  field :address,          type: String
  field :notes,       type: String


  embedded_in :meetup
  validates_presence_of     :name, :address
end
