//
// Created by Samuel Edwin on 6/1/16.
// Copyright (c) 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

@objc(OAuthToken)
public final class OAuthToken: NSObject {
    public var accessToken: String!
    public var expiry: String!
    public var refreshToken: String = ""
    public var tokenType: String!
    public var error: String?
    public var errorDescription: String?

    public class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from: [
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

extension OAuthToken: Unboxable {
    public convenience init(unboxer: Unboxer) throws {
        self.init()
        self.accessToken = try unboxer.unbox(keyPath: "access_token") as String
        self.expiry = try unboxer.unbox(keyPath: "expires_in") as String
        self.refreshToken = try unboxer.unbox(keyPath: "refresh_token") as String
        self.tokenType = try unboxer.unbox(keyPath: "token_type") as String
    }
}
