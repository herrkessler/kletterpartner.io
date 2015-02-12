class User
  include DataMapper::Resource
  include BCrypt
  include Gravatarify::Helper

  property :id, Serial, :key => true
  property :forename , String
  property :familyname , String, :lazy => [ :show ]
  property :username, String, :length => 3..50, :required => true, :unique => true, :lazy => [ :show ]
  property :email, String, :format => :email_address, :required => true, :unique => true, :lazy => [ :show ]
  property :password, BCryptHash, :lazy => [ :show ]
  property :admin, Boolean, :default  => false, :lazy => [ :show ]
  property :avatar, String
  property :gravatarURL, URI

  property :confirmed, Boolean, :default => false

  property :status, Enum[ :online, :offline, :idle ], :default => :offline, :lazy => [ :show ]

  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  is :friendly

  has n, :sites, :through => Resource
  has n, :conversations, :through => :participants
  has n, :participants

  before :save, :gravatar

  def gravatar
    self.gravatarURL = gravatar_url(self, :size => 200, :default => 'mm')
  end

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end