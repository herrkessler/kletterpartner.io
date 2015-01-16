class KletterPartner < Sinatra::Base

  # Messaging
  # -----------------------------------------------------------

  get '/users/:id/messages' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @user = User.get(params[:id])
    @my_conversations = @user.conversations.sort! {  |a, b|  a.update_at <=> b.update_at }
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

end