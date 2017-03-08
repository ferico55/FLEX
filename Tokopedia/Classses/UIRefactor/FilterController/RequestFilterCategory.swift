//
//  RequestFilterCategory.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilterCategory: NSObject {
    
    class func fetchListFilterCategory(_ ID:String, success: @escaping (([CategoryDetail]) -> Void), failed:@escaping ((Error)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        var path : String = "/v1/categories"
        
        if Int(ID) != 0  && Int(ID) != nil {
            path = "/v1/categories/\(ID)"
        }
        
        networkManager.request(
            withBaseUrl: NSString.hadesUrl(),
            path: path,
            method: .GET,
            parameter: ["filter":"type==tree"],
            mapping: CategoryResponse.mapping(),
            onSuccess: { (mappingResult, operation) in
                
                let result : Dictionary = mappingResult.dictionary() as Dictionary
                let response : CategoryResponse = result[""] as! CategoryResponse
                
                success(response.data.categories)
                
                
            },
            onFailure: { (error) in
                failed(error)
            })
    }


}
