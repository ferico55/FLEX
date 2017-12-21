//
//  RCAmount.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCAmount: NSObject {
    var idr: String = ""
    var integer: Int = 0
    override init(){}
    init(json:[String:JSON]) {
        if let integer = json["integer"]?.int {
            self.integer = integer
        }
        if let idr = json["idr"]?.string {
            self.idr = idr
        }
    }
}
