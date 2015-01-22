class KletterPartner < Sinatra::Base

  # Blog
  # -----------------------------------------------------------

  get '/blog' do
    unless env['warden'].user == nil
      @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
    end
    @posts = Post.all(:order => [:created_at.desc])
    slim :"post/index"
  end

  get '/blog/new' do
    if env['warden'].user.admin?
      unless env['warden'].user == nil
        @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
      end
      @post = Post.new
      slim :"post/new"
    else 
      flash[:error] = 'Youre not the admin'
      redirect to('/')
    end
  end

  post '/blog' do
    @post = Post.create(params[:post])
    flash[:success] = 'Neuer Post: "' + @post.title + '" angelegt'
    redirect to("/blog/#{@post.id}")
  end

  get '/blog/:id' do
    unless env['warden'].user == nil
      @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
    end
    @post = Post.get(params[:id])
    slim :"post/show"
  end
  
end