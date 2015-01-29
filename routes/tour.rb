class KletterPartner < Sinatra::Base

  # Blog
  # -----------------------------------------------------------

  get '/tour' do
    @sessionUser = env['warden'].user
    unless env['warden'].user == nil
      @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
    end
    slim :"tour/index"
  end
  
end