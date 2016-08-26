//
//  AnnouncementTickerRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTickerRequest: NSObject {
    func fetchTicker(successCallback: ((response: AnnouncementTickerResult) -> Void), errorCallback:((NSError) -> Void)) {
        let networkManager: TokopediaNetworkManager = TokopediaNetworkManager()
        
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.mojitoUrl(),
                                          path: "/api/v1/tickers",
                                          method: .GET,
                                          parameter: ["filter[device]":"ios",
                                            "page[size]":"50"],
                                          mapping: AnnouncementTicker.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            let result: Dictionary = mappingResult.dictionary() as Dictionary
                                            let response: AnnouncementTicker = result[""] as! AnnouncementTicker
                                            
                                            successCallback(response: response.data)
        }) { (error) in
            errorCallback(error)
        }
    }
}
