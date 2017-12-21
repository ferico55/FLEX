//
//  RCShippingDetail.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCShippingDetail: NSObject {
    var id: Int = 0
    var name: String = ""
    override init(){}
    init(json:[String:JSON]) {
        if let id = json["id"]?.int {
            self.id = id
        }
        if let name = json["name"]?.string {
            self.name = name
        }
    }
}
