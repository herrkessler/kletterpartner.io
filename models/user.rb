class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial, :key => true
  property :forename , String
  property :familyname , String, :lazy => [ :show ]
  property :username, String, :length => 3..50, :required => true, :unique => true, :lazy => [ :show ]
  property :email, String, :format => :email_address, :required => true, :unique => true, :lazy => [ :show ]
  property :password, BCryptHash, :lazy => [ :show ]
  property :admin, Boolean, :default  => false, :lazy => [ :show ]
  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  is :friendly

  has n, :sites, :through => Resource
  has n, :conversations, :through => :participants
  has n, :participants

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end