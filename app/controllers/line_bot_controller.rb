class LineBotController < ApplicationController
  require './app/controllers/rakuten_search_hotels_controller'
  require './app/controllers/recruit_search_gourmets_controller'
  protect_from_forgery except: [:callback]

  # LineBotの処理
  def callback
    body = request.body.read
    rakuten = RakutenSearchHotelsController.new
    recruit = RecruitSearchGourmetsController.new

    #LineBot 署名の検証
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature( body, signature )
      return head :bad_request 
    end

    events = client.parse_events_from( body )
    userid = events[0]['source']['userId']
    #メッセージがtext型か判別
    #ユーザーのトーク内容によって、返信の仕方を変更
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == '宿泊施設検索'
             UserState.create( userid: userid, status: 1 )
             message = {
              type: 'text',
              text: '宿泊施設を検索'
            }
            client.reply_message( event['replyToken'], message )

          elsif event.message['text'] == '飲食店検索'
            UserState.create( userid: userid, status: 2 )
            message = {
              type: 'text',
              text: '飲食店を検索'
            }
            client.reply_message( event['replyToken'], message )

          elsif UserState.exists?(userid: userid, status: 1)
            message = rakuten.search_hotel( event.message['text'] )
            client.reply_message( event['replyToken'], message )
            UserState.where(userid: userid).delete_all

          elsif UserState.exists?(userid: userid, status: 2)
            message = recruit.search_gourmet( event.message['text'] )
            client.reply_message( event['replyToken'], message )
            UserState.where(userid: userid).delete_all

          else
            message = {
              type: 'text',
              text: '無効なワードです。最初に「宿泊施設検索」を入力してください'
            }
            client.reply_message( event['replyToken'], message )
         end
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
