//
//  ReferralPromoContent.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 05/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
internal class ReferralPromoContent: NSObject {
    internal var code = ""
    internal var content = ""
    override internal init(){}
    internal init(json:[String:JSON]) {
        if let code = json["code"]?.string {
            self.code = code
        }
        if let content = json["content"]?.string {
            self.content = content
        }
    }
}
