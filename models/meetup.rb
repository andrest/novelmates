class Meetup
  include Mongoid::Document
  include Mongoid::Timestamps
  # timestamps!
  
  # self.include_root_in_json = true
  
  field :name,       type: String
  field :date,        type: String
  field :city,           type: String
  field :participants,        type: String :default => 0
  field :posts,           type: Hash,     :default => {}
  field :venue,        type: Hash,     :default => {}
  field :description,  type: String
  field :active,          type: Boolean,  :default => true
  
  def 
end
