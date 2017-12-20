import { TKPReactURLManager, ReactNetworkManager } from 'NativeModules'

export const getDigitalData = ({ userID, orderID, deviceToken }) =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.pulsaURL,
    path: '/v1.4/track/thankyou',
    encoding: 'json',    
    headers: {
        'content-type': 'application/json'
    },
    params: { 
        data: {            
            attributes: {
                order_id: orderID,
                identifier: {
                    device_token: deviceToken,
                    os_type: '2',
                    user_id: userID
                },
            },
            type: 'track_thankyou',
        },
    },
  })

  export const getMarketplaceData = ({ paymentID }) =>
  ReactNetworkManager.request({
    method: 'POST',
    baseUrl: TKPReactURLManager.paymentURL,
    path: '/graphql',
    encoding: 'json',    
    headers: {
        'content-type': 'application/json'
    },
    params: {
        query: `
        {
            payment(payment_id: ${payment}){
              payment_id
              payment_ref_num
              orders{
                  order_id
                  phone
              }
              partial {
                  amount
                  gateway{
                      gateway_name
                    gateway_img_url
                    gateway_id
                    }
              }
              payment_method{
                method
                instant{
                  gateway{
                      gateway_name
                    gateway_img_url
                    gateway_id
                    }
                }
                transfer{
                    destination_name
                    destination_account
                    source_account
                    source_name
                    gateway{
                      gateway_name
                    gateway_img_url
                    gateway_id
                    }
                }
                defer{
                    gateway{
                      gateway_name
                    gateway_img_url
                    gateway_id
                    }
                }
              }
            }
          }
        `
    },
  })

  