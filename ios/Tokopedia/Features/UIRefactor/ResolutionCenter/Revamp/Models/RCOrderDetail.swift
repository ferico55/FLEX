//
//  RCOrderDetail.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCOrderDetail: NSObject {
    var id: Int = 0
    var returnable: Int = 0
    var isFreeReturn: Bool {
        return (returnable == 3) ? true : false
    }
    override init(){}
    init(json:[String:JSON]) {
        if let id = json["id"]?.int {
            self.id = id
        }
        if let returnable = json["returnable"]?.int {
            self.returnable = returnable
        }
    }
}
