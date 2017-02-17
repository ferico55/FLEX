//
//  AnnouncementTickerRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTickerRequest: NSObject {
    func fetchTicker(_ successCallback: @escaping ((_ response: AnnouncementTickerResult) -> Void), errorCallback:@escaping ((Error) -> Void)) {
        let networkManager: TokopediaNetworkManager = TokopediaNetworkManager()
        
        networkManager.isUsingHmac = true
        
        networkManager.request(withBaseUrl: NSString.mojitoUrl(),
                               path: "/api/v1/tickers",
                               method: .GET,
                               parameter: ["filter[device]":"ios",
                                           "page[size]":"50"],
                               mapping: AnnouncementTicker.mapping(),
                               onSuccess: { (mappingResult, operation) in
                                let result: Dictionary = mappingResult.dictionary() as Dictionary
                                let response: AnnouncementTicker = result[""] as! AnnouncementTicker
                                
                                successCallback(response.data)
        }) { (error) in
            errorCallback(error)
        }
    }
}
