//
//  RequestFilterCategory.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestFilterCategory: NSObject {
    
    class func fetchListFilterCategory(success: (([CategoryDetail]) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString .hadesUrl(),
                                          path:"/v1/categories",
                                          method: .GET,
                                          parameter: ["filter":"type==tree"],
                                          mapping: CategoryResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : CategoryResponse = result[""] as! CategoryResponse
                                            
                                            success(response.result.categories)
                                            
                                            
        }) { (error) in
            failed(error)
        }
    }


}
