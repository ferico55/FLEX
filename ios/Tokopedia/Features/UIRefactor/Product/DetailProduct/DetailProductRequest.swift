//
//  DetailProductRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DetailProductRequest: NSObject {
    
    class func fetchPromoteProduct(_ productID:String, onSuccess: @escaping ((PromoteResult) -> Void), onFailure:@escaping ((PromoteResult) -> Void)) {

        let param :[String:String] = [
            "product_id" : productID
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString .v4Url(),
                                          path: "/v4/action/product/promote_product.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response<AnyObject>.mapping(withData: PromoteResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            guard let response : V4Response<AnyObject> = result[""] as? V4Response<AnyObject> else {
                                                return
                                            }
                                            guard let data = response.data as? PromoteResult else {
                                                return
                                            }
                                            
                                            if data.is_dink == "1" {
                                                onSuccess(data)
                                            } else {
                                                onFailure(data)
                                            }
                                            
        }) { (error) in
        }
    }
    
    class func fetchOtherProduct(_ productID:String, shopID:String, onSuccess: @escaping ((SearchAWSResult) -> Void),onFailure: @escaping (() -> Void)) {
        
        let param :[String:String] = [
            "shop_id" : shopID,
            "device" : "ios",
            "-id" : productID,
            "source":"other_product"
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString .aceUrl(),
                                          path: "/search/v2.3/product",
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response<AnyObject>.mapping(withData: SearchAWSResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                                            let data = response.data as! SearchAWSResult
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
}
