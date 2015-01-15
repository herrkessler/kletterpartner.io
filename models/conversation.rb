class Conversation
  include DataMapper::Resource

  property :id, Serial, :key => true

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  has n, :messages, :through => Resource
  has n, :participants, :through => Resource
  has n, :users, :through => :participants
end