class Message
  include DataMapper::Resource

  property :id, Serial, :key => true

  property :title, String, :required => true, :length => 128
  property :content, Text

  property :status, Enum[ :unread, :read, :deleted ], :default => :unread

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  belongs_to :conversation
end