//
//  RequestFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilter: NSObject {

    class func fetchListFilter(success: (([FilterObject]) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl("http://private-d6b26-rennyrun.apiary-mock.com",
                                          path:"/shipment",
                                          method: .GET,
                                          parameter: Dictionary(),
                                          mapping: FilterResponseObject.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : FilterResponseObject = result[""] as! FilterResponseObject
                                            
                                            success(response.list)
                                            
                                            
        }) { (error) in
            failed(error)
        }
    }
}
