class KletterPartner < Sinatra::Base

  # Blog
  # -----------------------------------------------------------

  get '/blog' do
    @posts = Post.all
    slim :"post/index"
  end

  get '/blog/new' do
    @post = Post.new
    slim :"post/new"
  end

  post '/blog' do
    @post = Post.create(params[:post])
    flash[:success] = 'Neuer Post: "' + @post.title + '" angelegt'
    redirect to("/blog/#{@post.id}")
  end

  get '/blog/:id' do
    @post = Post.get(params[:id])
    slim :"post/show"
  end
  
end