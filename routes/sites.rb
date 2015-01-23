class KletterPartner < Sinatra::Base

  # Site
  # -----------------------------------------------------------

  get '/sites' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
    @sites = Site.all.paginate(:page => params[:page], :per_page => 35)
    slim :"site/index", :layout => :layout_site
  end

  get '/sites-map', :provides => :json do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    sites = Site.all.paginate(:page => params[:page], :per_page => 35)
    return_data = [];
    return_data << @sessionUser
    return_data << sites
    halt 200, return_data.to_json
  end

  get '/sites/new' do
    env['warden'].authenticate!
    if env['warden'].user.admin?
      @sessionUser = env['warden'].user
      @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
      @site = Site.new
      slim :"site/new"
    else
      flash[:error] = 'Youre not the admin'
      redirect to('/')
    end
  end

  post '/sites' do
    env['warden'].authenticate!

    @sessionUser = env['warden'].user
    site = Site.create(params[:site])

    print site

    if site.saved? == true
      flash[:success] = 'Neuer Kletterhalle: "' + site.title + '" angelegt'
      redirect to("/sites/#{site.id}")
    else
      redirect to('/sites/new')
      flash[:error] = @site
    end
  end

  get '/sites/:id' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
    @site = Site.get(params[:id])
    if @site != nil
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