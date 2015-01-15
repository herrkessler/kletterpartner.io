class Site
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true, :length => 128
  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  has n, :users, :through => Resource
end