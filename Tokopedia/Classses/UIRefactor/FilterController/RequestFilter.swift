//
//  RequestFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilter: NSObject {

    class func fetchFilter(source: String, departmentID: String, success: ((response:FilterData) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.aceUrl(),
                                          path:"/v1/dynamic_attributes",
                                          method: .GET,
                                          parameter: ["source": source, "sc" : departmentID],
                                          mapping: FilterResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : FilterResponse = result[""] as! FilterResponse
                                            
                                            success(response: response.data)
                                            
        }) { (error) in
            failed(error)
        }
    }
}
