//
//  ProfileFavoriteRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class ProfileFavoriteRequest: NSObject {
    
    class func fetchListFavoriteShop(page:NSInteger, profileUserID:String, onSuccess: ((FavoriteShopResult) -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String: String] = [
            "page":"\(page)",
            "per_page":"5",
            "profile_user_id" : profileUserID
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/people/get_favorit_shop.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: FavoriteShop.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : FavoriteShop = result[""] as! FavoriteShop
                                            
                                            if response.message_error?.count > 0 {
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
