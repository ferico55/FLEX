//
// Created by Samuel Edwin on 6/1/16.
// Copyright (c) 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc(OAuthToken)
class OAuthToken: NSObject {
    var accessToken: String!
    var expiry: String!
    var refreshToken: String!
    var tokenType: String!

    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "access_token": "accessToken",
        ])

        return mapping
    }
}
