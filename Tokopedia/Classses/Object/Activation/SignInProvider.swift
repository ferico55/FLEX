//
//  SignInProvider.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class SignInProvider: NSObject {
    var id: String!
    var name: String!
    var signInUrl: String!
    var imageUrl: String!
    var color: String!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "id": "id",
            "name": "name",
            "url": "signInUrl",
            "image": "imageUrl",
            "color": "color"
        ])
        return mapping
    }
    
    class func defaultProviders() -> [SignInProvider] {
        return [
            {
                let provider = SignInProvider()
                provider.name = "Facebook"
                provider.id = "facebook"
                provider.imageUrl = "https://ecs1.tokopedia.net/img/icon/facebook_icon.png"
                provider.color = "#3A589B"
                return provider
            }(),
            {
                let provider = SignInProvider()
                provider.name = "Google+"
                provider.id = "gplus"
                provider.imageUrl = "https://ecs1.tokopedia.net/img/icon/gplus_icon.png"
                provider.color = "#FFFFFF"
                return provider
            }(),
            {
                let provider = SignInProvider()
                provider.name = "Yahoo"
                provider.id = "yahoo"
                provider.signInUrl = "https://\(NSString.accountsUrl())/wv/yahoo-login"
                provider.imageUrl = "https://ecs1.tokopedia.net/img/icon/yahoo_icon.png"
                provider.color = "#8B2491"
                return provider
            }()
        ]
    }
}
