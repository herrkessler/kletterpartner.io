class Confirmation
  include DataMapper::Resource

  property :id, Serial, :key => true

  property :code, String

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  belongs_to :user
end