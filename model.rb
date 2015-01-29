require 'bcrypt'

# -----------------------------------------------------------
# DataMapper Setup
# -----------------------------------------------------------

# DataMapper::Logger.new($stdout, :debug)
# DataMapper::setup(:default, "sqlite:kletterpartner.db")
DataMapper::Model.raise_on_save_failure = true 

configure :development do
  DataMapper::setup(:default, "postgres:kletterpartner")
end

configure :production do
  DataMapper::setup(:defaultt, ENV['HEROKU_POSTGRESQL_IVORY_URL'] || "postgres://gdvmfswxmmbcvb:wN5vnndqzGC3oJw5icH7Q_PL_A@https://guarded-retreat-9313.herokuapp.com/dbnt3lljncbi21")
end

# -----------------------------------------------------------
# Model and Associations
# -----------------------------------------------------------

require_relative 'models/user'
require_relative 'models/site'
require_relative 'models/post'
require_relative 'models/conversation'
require_relative 'models/message'
require_relative 'models/participant'
require_relative 'models/confirmation'

# -----------------------------------------------------------
# DataMapper Finalization
# -----------------------------------------------------------

DataMapper.finalize
DataMapper.auto_upgrade!

# -----------------------------------------------------------
# Create Dummy Data
# -----------------------------------------------------------

if User.count == 0
  @user = User.create(username: "admin", email: "sebastian@herrkessler.de")
  @user.password = "admin"
  @user.forename = "the ADMIN"
  @user.familyname = "Kessler"
  @user.admin = true
  @user.confirmed = true
  @user.avatar = "admin.png"
  @user.save
end

if Post.count == 0
  post = Post.new()
  post.attributes = {:title => 'Erster Eintrag'}
  post.synopsis = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  post.content = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  post.user_id = 1
  post.save
end