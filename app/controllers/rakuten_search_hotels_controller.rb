class RakutenSearchHotelsController < ApplicationController

  #楽天トラベルAPIを用いてホテルを検索
  def search_hotel( keyword )
    http_client = HTTPClient.new
    url = 'https://app.rakuten.co.jp/services/api/Travel/KeywordHotelSearch/20170426'
    query = {
      'keyword' => keyword,
      'hits' => 5,
      'responseType' => 'small',
      'formatVersion' => 2,
      'datumType' => 1,
      'applicationId' => ENV['RAKUTEN_APP_ID']
    }
    response = http_client.get( url, query )
    #rubyオブジェクトに変換
    data = JSON.parse( response.body )
    
    if data.key?( 'error' )
      text = "この検索条件で見つかる宿泊施設がありません。
      \n検索条件を変えてください\n例: 仙台　綺麗"
      {
        type: 'text',
        text: text
      }
    else
      {
        type: 'flex',
        altText: '宿泊施設の検索結果',
        contents: set_carousel( data['hotels'] )
      }
    end
  end

  private
  
    #Line flex message処理
    def set_carousel( hotels )
      bubbles = Array.new
      hotels.each do |hotel|
        bubbles.push(set_bubble( hotel[0]['hotelBasicInfo'] ))
      end
      {
        type: 'carousel',
        contents: bubbles
      }
    end

    def set_bubble( hotel )
      {
        type: 'bubble',
        hero: set_hero( hotel ),
        body: set_body( hotel ),
        footer: set_footer( hotel )
      }
    end

    def set_hero( hotel )
      {
        type: 'image',
        url: hotel['hotelImageUrl'],
        size: 'full',
        aspectRatio: '20:13',
        aspectMode: 'cover',
        action: {
          type: 'uri',
          uri:  hotel['hotelInformationUrl']
        }
      }
    end

    def set_body( hotel )
      {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: hotel['hotelName'],
            wrap: true,
            weight: 'bold',
            size: 'md'
          },
          {
            type: 'box',
            layout: 'vertical',
            margin: 'lg',
            spacing: 'sm',
            contents: [
              {
                type: 'box',
                layout: 'baseline',
                spacing: 'sm',
                contents: [
                  {
                    type: 'text',
                    text: '住所',
                    color: '#aaaaaa',
                    size: 'sm',
                    flex: 1
                  },
                  {
                    type: 'text',
                    text: hotel['address1'] + hotel['address2'],
                    wrap: true,
                    color: '#666666',
                    size: 'sm',
                    flex: 5
                  }
                ]
              },
              {
                type: 'box',
                layout: 'baseline',
                spacing: 'sm',
                contents: [
                  {
                    type: 'text',
                    text: '料金',
                    color: '#aaaaaa',
                    size: 'sm',
                    flex: 1
                  },
                  {
                    type: 'text',
                    text: '￥' + hotel['hotelMinCharge'].to_s() + '〜',
                    wrap: true,
                    color: '#666666',
                    size: 'sm',
                    flex: 5
                  }
                ]
              }
            ]
          }
        ]
      }
    end

    def set_footer( hotel )
      {
        type: 'box',
        layout: 'vertical',
        spacing: 'sm',
        contents: [
          {
            type: 'button',
            style: 'link',
            height: 'sm',
            action: {
              type: 'uri',
              label: '電話',
              uri: 'tel:' + hotel['telephoneNo']
            }
          },
          {
            type: 'button',
            style: 'link',
            height: 'sm',
            action: {
              type: 'uri',
              label: '地図',
              uri: 'https://www.google.com/maps?q=' + hotel['latitude'].to_s + ',' + hotel['longitude'].to_s
            }
          },
          {
            type: 'spacer',
            size: 'sm'
          }
        ],
        flex: 0
      }
    end

end
