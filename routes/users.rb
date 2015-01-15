class KletterPartner < Sinatra::Base

  # User
  # -----------------------------------------------------------

  get '/users' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @users = User.all.paginate(:page => params[:page], :per_page => 35)
    slim :"user/index"
  end

  get '/users/new' do
    @user = User.new
    slim :"user/new"
  end

  post '/users' do
    @user = User.create(params[:user])
    flash[:success] = 'Neuer User ' + @user.forename + ' angelegt'
    redirect to("/users/#{@user.id}")
  end

  get '/users/:id' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    @sessionUser = env['warden'].user
    slim :"user/show"
  end

  get '/users/:id/edit' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    slim :"user/edit"
  end

  put '/users/:id' do
    env['warden'].authenticate!
    user = User.get(params[:id])
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
    flash[:success] = 'Freundschaft mit ' + user.forename + ' angefragt'
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
    flash[:success] = 'Freundschaft mit ' + user.forename + ' beendet'
    redirect to("/users/#{sessionUser.id}")
  end

  # Friendship Requests
  # -----------------------------------------------------------

  get '/users/:id/friendship' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    slim :"user/friendship"
  end

end