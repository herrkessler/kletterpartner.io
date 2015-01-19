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

      user = User.get(sessionUser)
      user.update(:online => true)
      user.save

      flash[:success] = 'Hallo ' +sessionUser.forename+ ', du hast Dich erfolgreich eingeloggt.'
      redirect to("/")
    else
      redirect session[:return_to]
    end
  end
     
  get '/auth/logout' do
    sessionUser = env['warden'].user

    user = User.get(sessionUser)
    user.update(:online => false)
    user.save
    
    env['warden'].raw_session.inspect
    env['warden'].logout

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