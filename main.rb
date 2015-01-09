require 'bundler'
Bundler.require

require './model'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/assetpack'

class KletterPartner < Sinatra::Base

  # -----------------------------------------------------------
  # Settings
  # -----------------------------------------------------------

  set :root, File.dirname(__FILE__)

  enable :sessions
  enable :method_override
  enable :logging

  register Sinatra::Flash
  register Sinatra::AssetPack

  # -----------------------------------------------------------
  # Assets
  # -----------------------------------------------------------

  require 'sass'
  set :sass, { :load_paths => [ "#{KletterPartner.root}/app/css" ] }

  assets do
    serve '/js',     from: 'app/js'        # Default
    serve '/css',    from: 'app/css'       # Default
    serve '/images', from: 'app/images'    # Default

    js :app, '/js/app.js', [
      '/js/app.js'
    ]

    css :application, '/css/application.sass', [
      '/css/application.css'
    ]

    js_compression  :jsmin
    css_compression :sass 
  end

  # -----------------------------------------------------------
  # Authentication with Warden
  # -----------------------------------------------------------

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.get(id) }
    config.scope_defaults :default,
      strategies: [:password],
      action: 'auth/unauthenticated'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end

  Warden::Strategies.add(:password) do
    def valid?
      params['user'] && params['user']['username'] && params['user']['password']
    end

    def authenticate!
      user = User.first(username: params['user']['username'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['user']['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  # -----------------------------------------------------------
  # Helpers
  # -----------------------------------------------------------

  helpers do
  end

  # -----------------------------------------------------------
  # Routes
  # -----------------------------------------------------------

  # Index
  # -----------------------------------------------------------

  get '/' do
    slim :"index/index"
  end

  # Login
  # -----------------------------------------------------------

   get '/auth/login' do
     slim :"login"
   end

   post '/auth/login' do
    env['warden'].authenticate!
    flash[:success] = env['warden'].message
    if session[:return_to].nil?
      redirect '/'
    else
      redirect session[:return_to]
    end
  end
     
  get '/auth/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
    puts env['warden.options'][:attempted_path]
    puts env['warden']
    flash[:error] = env['warden'].message || "You must log in"
    redirect '/auth/login'
  end

  # User
  # -----------------------------------------------------------

  get '/users' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @users = User.all
    slim :"user/index"
  end

  get '/users/new' do
    env['warden'].authenticate!
    @user = User.new
    slim :"user/new"
  end

  post '/users' do
    @user = User.create(params[:user])
    env['warden'].authenticate!
    redirect to("/users/#{@user.id}")
  end

  get '/users/:id' do
    @user = User.get(params[:id])
    @sessionUser = env['warden'].user
    env['warden'].authenticate!
    slim :"user/show"
  end

  get '/users/:id/edit' do
    @user = User.get(params[:id])
    env['warden'].authenticate!
    slim :"user/edit"
  end

  put '/users/:id' do
    user = User.get(params[:id])
    env['warden'].authenticate!
    user.update(params[:user])
    if success
      redirect to("/users/#{user.id}")
    else
      redirect to("/users/#{user.id}/edit")
    end
  end

  delete '/users/:id' do
    env['warden'].authenticate!
    User.get(params[:id]).destroy
    redirect to('/users')
  end

  get '/users/:id/add' do
    env['warden'].authenticate!
    user = User.get(params[:id])
    sessionUser = env['warden'].user
    sessionUser.request_friendship(user)
    redirect to("/users/#{user.id}")
  end

  get '/users/:id/accept' do
    env['warden'].authenticate!
    user = User.get(params[:id])
    asker = User.get(1)
    sessionUser = env['warden'].user
    user.confirm_friendship_with(sessionUser)
    redirect to("/users/#{sessionUser.id}")
  end

  get '/users/:id/delete' do
    env['warden'].authenticate!
    user = User.get(params[:id])
    sessionUser = env['warden'].user
    user.end_friendship_with(sessionUser)
    redirect to("/users/#{sessionUser.id}")
  end

  # Friendships
  # -----------------------------------------------------------

  get '/users/:id/friendship' do
    env['warden'].authenticate!
    @user = env['warden'].user
    slim :"user/friendship"
  end

end