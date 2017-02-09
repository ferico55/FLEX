//
//  RetryPickupRequest.swift
//  Tokopedia
//
//  Created by Ronald on 2/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RetryPickupRequest: NSObject {
    class func retryPickupOrder(orderId: NSString, onSuccess:((V4Response) -> Void), onFailure:(() -> Void)) {
        let parameters : [String:String] = ["order_id": orderId as String]
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/myshop-order/retry_pickup.pl",
                                          method: .POST,
                                          parameter: parameters,
                                          mapping: V4Response.mappingWithData(GeneralActionResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(response)
                                            }
                                            },
                                          onFailure: {(error) in
                                                onFailure()
                                        })
    }
}
