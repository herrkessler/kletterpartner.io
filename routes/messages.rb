class KletterPartner < Sinatra::Base

  # Messaging
  # -----------------------------------------------------------

  get '/users/:id/messages' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    conversations = Conversation.all()
    @my_conversations = conversations.participants => @sessionUser
    slim :"message/index"
  end

end