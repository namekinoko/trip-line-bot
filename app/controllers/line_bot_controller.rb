class LineBotController < ApplicationController
  protect_from_forgery except: [:callback]

  # LineBotの処理
  def callback
    body = request.body.read

    #LineBot 署名の検証
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        return head :bad_request 
      end

        events = client.parse_events_from(body)
        p body
        #メッセージがtext型か判別
        events.each do |event|
          case event
          when Line::Bot::Event::Message
            case event.type
            when Line::Bot::Event::MessageType::Text
              message = search_hotel(event.message['text'])
            client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :ok
  end

    private
      def client
        @client ||= Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
        }
      end

      #楽天トラベルAPIを用いてホテルを検索
      def search_hotel( keyword )
        http_client = HTTPClient.new
        url = 'https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20170426'
        query = {
          'keyword' => keyword,
          'hits' => 5,
          'responseType' => 'small',
          'formatVersion' => 2,
          'applicationId' => ENV['RAKUTEN_APP_ID']
        }
        response = http_client.get(url,query)
        #rubyオブジェクトに変換
        data = JSON.parse(response.body)
        
        if data.key?('error')
          text = "この検索条件で見つかるホテル•旅館がありません。
          \n検索条件を変えてください\n例: 仙台　綺麗"
        else
          text = ''
          data['hotels'].each do |hotel|
            text <<
              hotel[0]['hotelBasicInfo']['hotelName'] + "\n" +
              hotel[0]['hotelBasicInfo']['hotelInformationUrl'] + "\n" +
            "\n"
         end
        end
        message = {
          type: 'text',
          text: text
        }
      end
end
