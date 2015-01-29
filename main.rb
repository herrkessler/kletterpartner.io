require 'bundler'
Bundler.require
require './model'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/assetpack'
require "sinatra/reloader"
require 'sinatra-websocket'
require 'will_paginate'
require 'will_paginate/data_mapper'
require 'json'
require 'pony'
require 'geokit'
require 'dm-serializer'
require 'redis'
require 'pusher'

class KletterPartner < Sinatra::Base

  # -----------------------------------------------------------
  # Sinatra Settings
  # -----------------------------------------------------------

  set :root, File.dirname(__FILE__)
  set :environments, %w{development production}
  set :session_secret, '*&(^B234'
  set :public_folder, 'public'
  set :server, 'thin'
  set :sockets, []

  $redis = Redis.new

  enable :sessions
  enable :method_override
  enable :logging

  register Sinatra::Flash
  register Sinatra::AssetPack


  # -----------------------------------------------------------
  # Pusher
  # -----------------------------------------------------------

  configure do
    register Sinatra::Reloader
    Pusher.app_id = '104514'
    Pusher.key = '5d1b84365243a919e503'
    Pusher.secret = 'fc3a6fdc7481e45eeeec'
  end


  # -----------------------------------------------------------
  # Assets
  # -----------------------------------------------------------

  require 'sass'
  set :sass, { :load_paths => [ "#{KletterPartner.root}/assets/css" ] }

  assets do
    serve '/js',     from: 'assets/js'        # Default
    serve '/css',    from: 'assets/css'       # Default
    serve '/images', from: 'assets/images'    # Default
    serve '/fonts',  from: 'assets/fonts'     # Default

    js :application, [
      '/js/lib/jquery-2.1.3.js',
      '/js/vendor/idle-timer.js',
      '/js/specific/menu.js',
      '/js/specific/idle.js',
      '/js/vendor/pusher.min.js',
      '/js/specific/status.js',
      '/js/specific/slider.js',
      '/js/specific/new_message.js'
    ]

    js :map, [
      '/js/vendor/mapbox.js',
      '/js/specific/map.js'
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

    def admin?
      user = User.first(username: params['user']['username'])

      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.admin?
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  # -----------------------------------------------------------
  # Helpers
  # -----------------------------------------------------------

  helpers WillPaginate::Sinatra::Helpers

  helpers do
    def paginate(collection)
       options = {
         inner_window: 0,
         outer_window: 0,
         previous_label: '&laquo;',
         next_label: '&raquo;'
       }
      will_paginate collection, options
    end
  end

  # -----------------------------------------------------------
  # Routes
  # -----------------------------------------------------------


  require_relative 'routes/index'
  require_relative 'routes/auth'
  require_relative 'routes/sites'
  require_relative 'routes/users'
  require_relative 'routes/blog'
  require_relative 'routes/messages'
  require_relative 'routes/admin'
  require_relative 'routes/tour'

end