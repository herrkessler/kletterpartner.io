require 'bcrypt'

# -----------------------------------------------------------
# DataMapper Setup
# -----------------------------------------------------------

# DataMapper::Logger.new($stdout, :debug)
DataMapper::setup(:default, "sqlite:kp-sinatra-2.db")
DataMapper::Model.raise_on_save_failure = true 

# -----------------------------------------------------------
# Model and Associations
# -----------------------------------------------------------

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

  def authenticate(attempted_password)
    if self.password == attempted_password
      true
    else
      false
    end
  end

end

class Site
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true, :length => 128
  property :created_at, DateTime, :lazy => [ :show ]
  property :update_at, DateTime, :lazy => [ :show ]

  has n, :users, :through => Resource
end

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

DataMapper.finalize
DataMapper.auto_upgrade!

# Create Admin User
if User.count == 0
  @user = User.create(username: "admin", email: "sebastian@herrkessler.de")
  @user.password = "admin"
  @user.forename = "Sebastian"
  @user.familyname = "Kessler"
  @user.admin = true
  @user.save
end

# Create initial Post
if Post.count == 0
  post = Post.new()
  post.attributes = {:title => 'Erster Eintrag'}
  post.synopsis = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  post.content = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
  post.user_id = 1
  post.save
end