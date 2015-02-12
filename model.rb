require "bcrypt"
require "dm-postgres-types"
require "gravatarify"

# -----------------------------------------------------------
# DataMapper Setup
# -----------------------------------------------------------

# DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true 
DataMapper::setup(:default, "postgres:kletterpartner")

# :production
#   DataMapper::setup(:default, ENV["HEROKU_POSTGRESQL_IVORY_URL"] || "postgres://gdvmfswxmmbcvb:wN5vnndqzGC3oJw5icH7Q_PL_A@ec2-107-20-191-205.compute-1.amazonaws.com/dbnt3lljncbi21")

# -----------------------------------------------------------
# Model and Associations
# -----------------------------------------------------------

require_relative "models/user"
require_relative "models/site"
require_relative "models/post"
require_relative "models/conversation"
require_relative "models/message"
require_relative "models/participant"
require_relative "models/confirmation"

# -----------------------------------------------------------
# DataMapper Finalization
# -----------------------------------------------------------

DataMapper.finalize
DataMapper.auto_upgrade!

# -----------------------------------------------------------
# Create Dummy Data
# -----------------------------------------------------------

if User.count == 0
  @user = User.new()
  @user.username = "admin"
  @user.email = "admin@kletterpartner.io"
  @user.password = "admin"
  @user.forename = "the ADMIN"
  @user.familyname = ""
  @user.admin = true
  @user.confirmed = true
  @user.avatar = "admin.png"
  @user.save
end

if Post.count == 0
  post = Post.new()
  post.title = "Erster Eintrag"
  post.synopsis = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  post.content = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  post.user_id = 1
  post.save
end

if Site.count == 0

  site = Site.new()
  site.attributes = {:title => "Wupperwaende"}
  site.description = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
  site.street = "Badische Str. 76 "
  site.zip = "42389"
  site.town = "Wuppertal"
  site.url = "http://www.wupperwaende.de/"
  site.size = "1300"
  site.climb = true
  site.boulder = true
  site.max_height = "16"
  site.opening_hours = {mon: "10.00 - 23.00", tue: "10.00 - 23.00", wed: "10.00 - 23.00", thu: "10.00 - 23.00", fri: "10.00 - 23.00", sat: "10.00 - 23.00", sun: "10.00 - 23.00"}
  site.rating = "4"
  site.rating_users = ["1"]
  site.save
end