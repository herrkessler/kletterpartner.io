class Participant
  include DataMapper::Resource

  property :id, Serial, :key => true

  belongs_to :conversation
  belongs_to :user
end