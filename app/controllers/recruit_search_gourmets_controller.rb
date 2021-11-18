class RecruitSearchGourmetsController < ApplicationController

  #リクルート•グルメAPIを用いて飲食店を検索
  def search_gourmet( keyword )
    http_client = HTTPClient.new
    url = 'http://webservice.recruit.co.jp/hotpepper/gourmet/v1/'
    query = {
      'key' => ENV['RECRUIT_APP_ID'],
      'keyword' => keyword,
      'format' => 'json',
      'order' => 4,
      'count' => 5,
    }
    response = http_client.get( url, query )
    #rubyオブジェクトに変換
    data = JSON.parse( response.body )
    if data['results']['results_available'] == 0
      text = "この検索条件で見つかる飲食店がありません。
      \n検索条件を変えてください\n例: 仙台"
      {
        type: 'text',
        text: text
      }
    else
      {
        type: 'flex',
        altText: '飲食店の検索結果',
        contents: set_carousel( data['results']['shop'] )
      }
    end

  end

  #Line Flex message処理
  private
    def set_carousel( shops )
      bubbles = Array.new
      shops.each do |shop|
        bubbles.push( set_bubble( shop ) )
      end
      {
        type: 'carousel',
        contents: bubbles
      }
    end

    def set_bubble( shop )
      {
        type: 'bubble',
        hero: set_hero( shop ),
        body: set_body( shop ),
        footer: set_footer( shop )
      }
    end

    def set_hero( shop )
      {
        type: 'image',
        url: shop['photo']['mobile']['s'],
        size: 'full',
        aspectRatio: '20:13',
        aspectMode: 'cover',
        action: {
          type: 'uri',
          uri:  shop['urls']['pc']
        }
      }
    end

    def set_body( shop )
      {
        type: 'box',
        layout: 'vertical',
        contents: [
          {
            type: 'text',
            text: shop['name'],
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
                    text: shop['address'],
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
                    text: '予算',
                    color: '#aaaaaa',
                    size: 'sm',
                    flex: 1
                  },
                  {
                    type: 'text',
                    text: shop['budget']['average'],
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

    def set_footer( shop )
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
              label: 'ウェブサイト',
              uri: shop['urls']['pc']
            }
          },
          {
            type: 'button',
            style: 'link',
            height: 'sm',
            action: {
              type: 'uri',
              label: '地図で確認',
              uri: 'https://www.google.com/maps?q=' + shop['lat'].to_s + ',' + shop['lng'].to_s
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
