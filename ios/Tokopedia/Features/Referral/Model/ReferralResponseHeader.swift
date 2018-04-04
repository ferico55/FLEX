//
//  ReferralResponseHeader.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
internal class ReferralResponseHeader: NSObject {
    internal var message: [String]?
    internal var reason: String?
    internal var errorCode = 0
    override internal init(){}
    internal init(json:[String:JSON]) {
        if let message = json["messages"]?.arrayObject as? [String] {
            self.message = message
        }
        if let reason = json["reason"]?.string {
            self.reason = reason
        }
        if let errorCode = json["error_code"]?.int {
            self.errorCode = errorCode
        }
    }
}
