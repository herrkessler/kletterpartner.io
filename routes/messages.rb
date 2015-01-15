class KletterPartner < Sinatra::Base

  # Messaging
  # -----------------------------------------------------------

  get '/users/:id/messages' do
    env['warden'].authenticate!
    @sessionUser = env['warden'].user
    @user = User.get(params[:id])
    @my_conversations = @user.conversations.sort! {  |a, b|  a.update_at <=> b.update_at }
    @email_stats = @my_conversations.messages.map(&:status)
    slim :"message/index"
  end

end