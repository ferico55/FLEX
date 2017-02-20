//
//  RequestFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilter: NSObject {
    
    class func fetchFilter(_ source: String, departmentID: String, success: @escaping ((_ response:FilterData) -> Void), failed:@escaping ((Error)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(
            withBaseUrl: NSString.aceUrl(),
            path:"/v1/dynamic_attributes",
            method: .GET,
            parameter: ["source": source, "sc" : departmentID],
            mapping: FilterResponse.mapping(),
            onSuccess: { (mappingResult, operation) in
                
                let result : Dictionary = mappingResult.dictionary() as Dictionary
                let response : FilterResponse = result[""] as! FilterResponse
                
                success(response.data)
        }, onFailure: { (error) in
            failed(error)
        })
    }
}
