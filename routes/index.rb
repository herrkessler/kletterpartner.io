class KletterPartner < Sinatra::Base

  # Index
  # -----------------------------------------------------------

  get '/' do
    unless env['warden'].user == nil
      @email_stats ||=env['warden'].user.conversations.messages.reject { |h| [env['warden'].user.id].include? h['sender'] }.map(&:status) || halt(404)
    end
    slim :"index/index"
  end
end