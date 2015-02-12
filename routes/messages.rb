class KletterPartner < Sinatra::Base

  # Messaging
  # -----------------------------------------------------------

  get '/users/:id/messages' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @user = User.get(params[:id])
    @my_conversations = @user.conversations.sort! {  |a, b|  a.update_at <=> b.update_at }.reverse
    @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)
    @newest_conversation = @my_conversations.first
    slim :"message/index"
  end

  # Get Conversation messages
  # --------------------------

  get '/users/:id/messages/:conversation' do
    content_type :json
    conversation = Conversation.get(params[:conversation])
    messages = conversation.messages
    messages.to_json
  end

  # New Message
  # --------------------------

  post '/users/:id/messages/:conversation', :provides => :json do

    sessionUser = env['warden'].user

    @conversation = Conversation.get(params[:conversation])

    @message = Message.new()
    @message.attributes = {:conversation => @conversation, :content => params['message'], :sender => sessionUser.id}
    @message.save

    @conversation.messages << @message
    @conversation.save
    @conversation.messages.save

    @conversation.update(:update_at => Time.now)

    reciever = @conversation.participants.select {|p| p["user_id"] != sessionUser.id }

    channel = "conversation_#{@conversation.id}"

    Pusher[channel].trigger('new_message', :message => params['message'], :sender => sessionUser.id, :timestamp => Time.now.strftime("%H:%M:%S"), :conversation => @conversation.id)
    Pusher['realtime'].trigger('new_message', :sender => sessionUser.id, :reciever => reciever[0].user_id)

    halt 200
  end

  # New Conversation
  # --------------------------

  post '/users/:id/new-message/:reciever', :provides => :json do
    data = request.body.read

    sessionUser = env['warden'].user

    conversation = Conversation.new()
    conversation.save

    message = Message.new()
    message.attributes = {:conversation => conversation, :content => data, :sender => sessionUser.id}
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

    Pusher['realtime'].trigger('update_message', :conversation => conversation.id, :reciever => recieverUser.id)

    halt 200, conversation.id.to_json
  end

  # Update Conversation Status
  # --------------------------

  get '/users/:id/conversation/:conversation', :provides => :json do
    sessionUser = env['warden'].user
    conversation = Conversation.get(params[:conversation])
    messages = conversation.messages
    messages.all.update(:status => :read)
    reciever = conversation.participants.select {|p| p["user_id"] = sessionUser.id }
    Pusher['realtime'].trigger('update_message', :conversation => conversation.id, :reciever => reciever[0].user_id)
    halt 200
  end

  # Delete Conversation
  # --------------------------

  get '/conversation/:id/delete', :provides => :json do
    conversation = Conversation.get(params[:id])

    ConversationParticipant.all(:conversation_id => conversation.id).destroy
    ConversationMessage.all(:conversation_id => conversation.id).destroy
    Participant.all(:conversation_id => conversation.id).destroy
    Message.all(:conversation_id => conversation.id).destroy

    conversation.destroy!

    halt 200, conversation.id.to_json
  end

end