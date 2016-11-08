//
//  DetailProductRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DetailProductRequest: NSObject {
    
    class func fetchPromoteProduct(productID:String, onSuccess: ((PromoteResult) -> Void)) {

        let param :[String:String] = [
            "product_id" : productID
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/promote_product.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(PromoteResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response = result[""] as! V4Response
                                            let data = response.data as! PromoteResult
                                            
                                            if data.is_dink == "1" {
                                                StickyAlertView.showSuccessMessage(["Promo pada product \(data.product_name) telah berhasil! Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko."])
                                                onSuccess(data)
                                            } else {
                                                StickyAlertView.showErrorMessage(["Anda belum dapat menggunakan fitur Promo pada saat ini. Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko."])
                                            }
                                            
        }) { (error) in
        }
    }
    
    class func fetchOtherProduct(productID:String, shopID:String, onSuccess: ((SearchAWSResult) -> Void),onFailure: (() -> Void)) {
        
        let param :[String:String] = [
            "shop_id" : shopID,
            "device" : "ios",
            "-id" : productID,
            "source":"other_product"
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString .aceUrl(),
                                          path: "/search/v2.3/product",
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(SearchAWSResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response = result[""] as! V4Response
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
