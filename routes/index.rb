class KletterPartner < Sinatra::Base

  # Index
  # -----------------------------------------------------------

  get '/' do
    if !request.websocket?
      unless env['warden'].user == nil
        @email_stats ||= env['warden'].user.conversations.messages.map(&:status) || halt(404)
      end

      slim :"index/index"
    else
      request.websocket do |ws|
        ws.onopen do
          ws.send("Hello World!")
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end

    end
  end
end