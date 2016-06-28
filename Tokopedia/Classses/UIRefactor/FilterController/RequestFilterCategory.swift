//
//  RequestFilterCategory.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilterCategory: NSObject {
    
    class func fetchListFilterCategory(ID:String, success: (([CategoryDetail]) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        var path : String = "/v1/categories"
        
        if Int(ID) != 0  && Int(ID) != nil {
            path = "/v1/categories/\(ID)"
        }
        
        networkManager.requestWithBaseUrl(NSString .hadesUrl(),
                                          path: path,
                                          method: .GET,
                                          parameter: ["filter":"type==tree"],
                                          mapping: CategoryResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : CategoryResponse = result[""] as! CategoryResponse
                                            
                                            success(response.data.categories)
                                            
                                            
        }) { (error) in
            failed(error)
        }
    }


}
