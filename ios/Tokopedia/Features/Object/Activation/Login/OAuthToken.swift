//
// Created by Samuel Edwin on 6/1/16.
// Copyright (c) 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

@objc(OAuthToken)
public class OAuthToken: NSObject {
    public var accessToken: String!
    public var expiry: String!
    public var refreshToken: String = ""
    public var tokenType: String!
    public var error: String?
    public var errorDescription: String?

    class public func mapping() -> RKObjectMapping {
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
