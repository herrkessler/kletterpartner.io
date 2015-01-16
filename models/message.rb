class Message
  include DataMapper::Resource

  property :id, Serial, :key => true

  property :content, Text
  property :sender, Integer

  property :status, Enum[ :unread, :read, :deleted ], :default => :unread

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  belongs_to :conversation
end