class KletterPartner < Sinatra::Base

  # Site
  # -----------------------------------------------------------

  get '/sites' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @sites = Site.all.paginate(:page => params[:page], :per_page => 35)
    slim :"site/index"
  end

  get '/sites/new' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @site = Site.new
    slim :"site/new"
  end

  post '/sites' do
    env['warden'].authenticate!
    @post = Site.create(params[:post])
    @sessionUser = env['warden'].user
    flash[:success] = 'Neuer Kletterhalle: "' + @site.title + '" angelegt'
    redirect to("/sites/#{@site.id}")
  end

  get '/sites/:id' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    if @site != nil
      @site = Site.get(params[:id])
      slim :"site/show"
    else
      flash[:error] = 'What you are looking for does not exist'
      redirect to("/sites")
    end
  end

  get '/sites/:id/add/:user' do
    env['warden'].authenticate!
    site = Site.get(params[:id])
    user = User.get(params[:user])
    site.users << user
    site.save
    site.users.save
    flash[:success] = 'Kletterhalle: "' + site.title + '" zu Deinen Favouriten hinzugefuegt'
    redirect to("/sites/#{site.id}")
  end

  get '/sites/:id/delete/:user' do
    env['warden'].authenticate!
    site = Site.get(params[:id])
    user = User.get(params[:user])
    SiteUser.all(:user_id => user.id, :site_id => site.id).destroy
    flash[:success] = 'Kletterhalle: "' + site.title + '" aus Deinen Favouriten entfernt'
    redirect to("/sites/#{site.id}")
  end

end