class Meetup
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :name,          type: String
  field :date,          type: DateTime
  field :city,          type: String
  field :creator,       type: String
  field :notify_ids,  type: Array,   :default  => []
  field :posts,         type: Hash,     :default  => {}
  field :description,   type: String
  field :active,        type: Boolean,  :default  => true
  field :books,         type: Array

  embeds_one :venue
  embeds_many :posts
  has_and_belongs_to_many :users
  validates_presence_of     :name, :books, :city, :creator

  validate :date_is_ok?

  def date_is_ok?
    unless self.date.to_i > Time.now.to_i || self.date.nil?
       errors.add :date, "Date must be in the future"
       return false
    end
    true
  end
end
