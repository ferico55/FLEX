//
//  RequestFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilter: NSObject {

    class func fetchFilter(success: ((response:FilterResponse) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl("http://private-ccbb0-dynamicfilter.apiary-mock.com",
                                          path:"/filter",
                                          method: .GET,
                                          parameter: Dictionary(),
                                          mapping: FilterResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : FilterResponse = result[""] as! FilterResponse
                                            
                                            success(response: response)
                                            
        }) { (error) in
            failed(error)
        }
    }
}
