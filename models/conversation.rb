class Conversation
  include DataMapper::Resource

  property :id, Serial, :key => true

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  has n, :messages, :through => Resource, :constraint => :skip
  has n, :participants, :through => Resource, :constraint => :skip
  has n, :users, :through => :participants, :constraint => :skip
end