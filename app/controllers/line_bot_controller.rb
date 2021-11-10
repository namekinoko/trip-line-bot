class LineBotController < ApplicationController
  require './app/controllers/rakuten_search_hotels_controller'
  protect_from_forgery except: [:callback]

  # LineBotの処理
  def callback
    body = request.body.read
    rakuten = RakutenSearchHotelsController.new

      #LineBot 署名の検証
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature( body, signature )
        return head :bad_request 
      end

      events = client.parse_events_from( body )
      #メッセージがtext型か判別
      events.each do |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
              message = rakuten.search_hotel( event.message['text'] )
              client.reply_message( event['replyToken'], message )
            end
          end
        end
      head :ok
    end

    private
    # Lineのクライアント
      def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
      end

end
