class KletterPartner < Sinatra::Base

  # Login
  # -----------------------------------------------------------

   get '/auth/login' do
     slim :"login"
   end

   post '/auth/login' do
    env['warden'].authenticate!
    if session[:return_to].nil?
      sessionUser = env['warden'].user

      user = User.get(sessionUser.id)
      user.update(:status => :online)
      user.update(:update_at => Time.now)

      $redis.sadd 'online_users', sessionUser.id

      Pusher.trigger('online_users', 'status', {:message => $redis.smembers('online_users')})

      flash[:success] = 'Hallo ' +sessionUser.forename+ ', du hast Dich erfolgreich eingeloggt.'
      redirect to("/")
    else
      redirect session[:return_to]
    end
  end
     
  get '/auth/logout' do
    sessionUser = env['warden'].user

    user = User.get(sessionUser.id)
    user.update(:status => :offline)
    
    env['warden'].raw_session.inspect
    env['warden'].logout

    $redis.srem 'online_users', sessionUser.id

    Pusher.trigger('online_users', 'status', {:message => $redis.smembers('online_users')})

    flash[:success] = 'Du hast Dich erfolgreich ausgeloggt.'
    redirect '/'
  end

  post '/auth/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path] if session[:return_to].nil?
    puts env['warden.options'][:attempted_path]
    puts env['warden']
    flash[:error] = env['warden'].message || "Fehler bei Anmeldung"
    redirect '/auth/login'
end

end