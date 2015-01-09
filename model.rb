require 'bcrypt'

# -----------------------------------------------------------
# DataMapper Setup
# -----------------------------------------------------------

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
  property :familyname , String
  property :username, String, :length => 3..50, :required => true, :unique => true
  property :email, String, :format => :email_address, :required => true, :unique => true
  property :password, BCryptHash
  property :admin, Boolean, :default  => false
  property :created_at, DateTime
  property :update_at, DateTime

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
  property :title, String, :required => true
  property :created_at, DateTime
  property :update_at, DateTime

  has n, :users, :through => Resource
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