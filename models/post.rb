class Post
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :title, String
  property :synopsis, Text
  property :content, Text
  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  belongs_to :user
end