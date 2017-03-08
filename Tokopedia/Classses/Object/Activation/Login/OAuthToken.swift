//
// Created by Samuel Edwin on 6/1/16.
// Copyright (c) 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

@objc(OAuthToken)
class OAuthToken: NSObject {
    var accessToken: String!
    var expiry: String!
    var refreshToken: String = ""
    var tokenType: String!
    var error: String?
    var errorDescription: String?

    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "access_token": "accessToken",
            "token_type": "tokenType",
            "expires_in": "expiry",
            "refresh_token": "refreshToken",
            "error": "error",
            "error_description": "errorDescription"
        ])

        return mapping!
    }
}
