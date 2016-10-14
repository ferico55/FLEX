//
//  shopRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ShopRequest: NSObject {
    
    class func fetchListShopFavorited(page:NSInteger, shopID:String, onSuccess: ((FavoritedResult) -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String : String] = [
            "page":"\(page)",
            "shop_id":shopID
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/shop/get_people_who_favorite_myshop.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(FavoritedResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response<FavoritedResult>
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }

}
