class KletterPartner < Sinatra::Base

  # Messaging
  # -----------------------------------------------------------

  get '/users/:id/messages' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @user = User.get(params[:id])
    @my_conversations = @user.conversations.sort! {  |a, b|  a.update_at <=> b.update_at }.reverse
    @email_stats = @my_conversations.messages.map(&:status)
    @newest_conversation = @my_conversations.first
    slim :"message/index"
  end

  get '/users/:id/messages/:conversation' do
    content_type :json
    conversation = Conversation.get(params[:conversation])
    messages = conversation.messages
    messages.to_json
  end

  post '/users/:id/messages/:conversation', :provides => :json do
    data = request.body.read

    sessionUser = env['warden'].user

    @conversation = Conversation.get(params[:conversation])

    @message = Message.new()
    @message.attributes = {:conversation => @conversation, :content => data, :sender => sessionUser.id}
    @message.save

    @conversation.messages << @message
    @conversation.save
    @conversation.messages.save

    @conversation.update(:update_at => Time.now)

    halt 200, data.to_json
  end

  post '/users/:id/new-message/:reciever', :provides => :json do
    data = request.body.read

    conversation = Conversation.new()
    conversation.save

    message = Message.new()
    message.attributes = {:conversation => conversation, :content => data, :sender => params([:id])}
    message.save

    sender = Participant.new()
    senderUser = env['warden'].user
    sender.attributes = {:conversation => conversation, :user => senderUser}
    sender.save

    reciever = Participant.new()
    recieverUser = User.get(params[:reciever])
    reciever.attributes = {:conversation => conversation, :user => recieverUser}
    reciever.save

    conversation.messages << message
    conversation.participants << sender
    conversation.participants << reciever
    conversation.save
    conversation.messages.save
    conversation.participants.save

    conversation.update(:update_at => Time.now)

    halt 200, data.to_json
  end

end