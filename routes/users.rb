class KletterPartner < Sinatra::Base

  # User
  # -----------------------------------------------------------

  get '/users' do
    env['warden'].authenticate!
    if env['warden'].user.admin?
      @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)
      @sessionUser = env['warden'].user
      @users = User.all(:order => [:username.asc]).paginate(:page => params[:page], :per_page => 100)
      slim :"user/index"
    else 
      flash[:error] = 'Youre not the admin'
      redirect to('/')
    end
  end

  get '/users/new' do
    @user = User.new
    slim :"user/new"
  end

  post '/users' do

    data = params[:user]

    if data[:username].empty? or data[:email].empty? or data[:password].empty?
      flash[:error] = 'Something was missing'
      redirect to("/users/new")
    elsif data[:password] != data[:repeated_password]
      flash[:error] = 'Your passwords did not match'
      redirect to("/users/new")
    else
      data = data.except('repeated_password')
      admin = User.get(1)
      @user = User.create(data)

      if @user.saved?

        admin.request_friendship(@user)

        @confirmation = Confirmation.new()
        @confirmation.attributes = {:user => @user, :code => SecureRandom.uuid}
        @confirmation.save

        # Send welcome mail

        mandrill = Mandrill::API.new 'szZU6o0dhGUZ-e2dQEqdyg'
        message = {
            :subject => 'Howdy, ' + @user.forename,
            :from_name => "hello@kletterpartner.io",
            :text => 'Willkommen bei kletterpartner.io, your place to find new climbers.',
            :to => [
                {
                    :email => @user.email,
                    :name => @user.forename
                 }
            ],
            :html =>'<html><b>Willkommen bei kletterpartner.io, your place to find new climbers.</b><br /><p>Hallo '+@user.forename+',</p><p>bitte bestaetige Deine Email Adresse ueber diesen Link:<p><a href="http://localhost:9292/users/'+@user.id.to_s+'/confirm/'+@confirmation.code.to_s+'">http://kletterpartner.io/users/'+@user.id.to_s+'/confirm/'+@confirmation.code.to_s+'</a></html>',
            :from_email => "hello@kletterpartner.io"
        }
        sending = mandrill.messages.send message

        # Send first chat message from Admin

        conversation = Conversation.new()
        conversation.save

        message = Message.new()
        message.attributes = {:conversation => conversation, :content => "Welcome to kletterpartner.io, your place to find new climbers. Yours Sebastian aka The ADMIN ;)", :sender => admin.id}
        message.save

        sender = Participant.new()
        senderUser = admin
        sender.attributes = {:conversation => conversation, :user => senderUser}
        sender.save

        reciever = Participant.new()
        recieverUser = @user
        reciever.attributes = {:conversation => conversation, :user => recieverUser}
        reciever.save

        conversation.messages << message
        conversation.participants << sender
        conversation.participants << reciever
        conversation.save
        conversation.messages.save
        conversation.participants.save

        conversation.update(:update_at => Time.now)

        # Redirect to login

        flash[:new_user] = 'Hallo ' + @user.forename + ', du brauchst noch etwas Geduld... bitte bestaetige erst deine Email Adresse.'
        redirect to("/auth/login")

      else

        flash[:error] = 'Something went wrong while signing up'
        redirect to("/users/new")

      end
    end
  end

  get '/users/:id' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    @user_friends = @user.friends.sort_by {|friend| friend.forename}
    @user_sites = @user.sites.sort_by {|site| site.title}
    @friends = Friendship.all
    @messages = Message.all
    @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)

    # # Find User with most friendships

    # friend_user = Hash.new 0
    # user_friend = Hash.new 0
    # @friends.each do |friend|
    #   friend_user[friend.user_id] += 1
    # end
    # @friends.each do |friend|
    #   user_friend[friend.friend_id] += 1
    # end
    # result_1 = friend_user.max_by{|k,v| v}
    # result_2 = user_friend.max_by{|k,v| v}
    # final_result = []
    # final_result << user_friend
    # final_result << friend_user
    # sorted_final_results = final_result.inject{|memo, el| memo.merge( el ){|k, old_v, new_v| old_v + new_v}}
    # user_with_most_friends = sorted_final_results.max_by{ |k,v| v }[0]
    # @most_friends = User.get(user_with_most_friends)

    # # Find User with most messages

    # messages_user = Hash.new 0
    # @messages.each do |message|
    #   messages_user[message.sender] += 1
    # end
    # user_with_most_messages = messages_user.max_by{ |k,v| v }[0]
    # @messages_amount = messages_user.max_by{ |k,v| v }[1]
    # @most_messages = User.get(user_with_most_messages)

    # # Find User with most sites

    # sites_user = SiteUser.all
    # freq = sites_user.inject(Hash.new(0)) { |h,v| h[v.user_id] += 1; h }
    # user_with_most_sites = freq.max_by{ |k,v| v }[0]
    # @most_sites = User.get(user_with_most_sites)

    # Render View

    if @user != nil
      @sessionUser = env['warden'].user
      slim :"user/show"
    else
      flash[:error] = 'What you are looking for does not exist'
      redirect to("/")
    end
  end

  get '/users/:id/edit' do
    env['warden'].authenticate!
    @user = User.get(params[:id])
    @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)
    slim :"user/edit"
  end

  put '/users/:id' do
    env['warden'].authenticate!
    user = User.get(params[:id])
    user.update(params[:user])
    if user.saved?
      flash[:success] = 'User update successful'
      redirect to("/users/#{user.id}")
    else
      flash[:error] = 'Something went wrong'
      redirect to("/users/#{user.id}/edit")
    end
  end

  post '/users/:id/avatar' do

    sessionUser = env['warden'].user
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    FileUtils::mkdir_p 'public/images/' + sessionUser.id.to_s
    filepath = 'public/images/' + sessionUser.id.to_s
    FileUtils.move file.to_path, File.join(filepath, params[:file][:filename])
    user = User.get(sessionUser.id)
    user.update(:avatar => @filename)
    if user.saved?
      flash[:success] = 'Bild hochgeladen'
      redirect to("/users/#{user.id}")
    else
      flash[:error] = 'Something went wrong'
      redirect to("/users/#{user.id}/edit")
    end
  end

  delete '/users/:id' do
    env['warden'].authenticate!
    User.get(params[:id]).destroy
    redirect to('/')
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
    @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)
    slim :"user/friendship"
  end

  # Status Update
  # -----------------------------------------------------------

  get '/user/idle', :provides => :json do
    sessionUser = env['warden'].user
    user = User.get(sessionUser.id)
    user.update(:status => :idle)
    $redis.hset(sessionUser.id, 'status', 'idle')
    Pusher.trigger('user_status', 'status', {:status => $redis.hget(sessionUser.id, 'status'), :user => sessionUser.id})
    halt 200
  end

  get '/user/online', :provides => :json do
    sessionUser = env['warden'].user
    user = User.get(sessionUser.id)
    user.update(:status => :online)
    $redis.hset(sessionUser.id, 'status', 'online')
    Pusher.trigger('user_status', 'status', {:status => $redis.hget(sessionUser.id, 'status'), :user => sessionUser.id})
    halt 200
  end

  # Confirm Email
  # -----------------------------------------------------------

  get '/users/:id/confirm/:code' do

    user = User.get(params[:id])
    confirmation = Confirmation.first(:code => params[:code])

    if params[:code] == confirmation.code

      confirmation.attributes = {:code => ""}
      confirmation.save

      user.attributes = {:confirmed => true}
      user.save

      flash[:new_user] = 'Prost ' + user.forename + ', es kann losgehen, log Dich ein und finde neue Kletterpartner.'
      redirect to("/auth/login")
    else
      flash[:error] = 'Something went terribly wrong here with your email confirmation...'
      redirect to("/")
    end
  end

end