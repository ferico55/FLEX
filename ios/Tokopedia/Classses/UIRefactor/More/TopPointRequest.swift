//
//  TopPointRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class TopPointRequest: NSObject {
    
    class func fetchTopPoint(_ onSuccess: @escaping ((LoyaltyPointResult) -> Void)) {

        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString .pointUrl(),
                                          path: "/app/v4",
                                          method: .POST,
                                          parameter: [:],
                                          mapping:  V4Response<AnyObject>.mapping(withData: LoyaltyPointResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response = result[""] as! V4Response<LoyaltyPointResult>
                                            let data = response.data as LoyaltyPointResult
                                            
                                            guard response.data != nil else {
                                                return
                                            }
                                            
                                            onSuccess(data)
                                            
        }) { (error) in
        }
    }

}
