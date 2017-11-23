//
//  ShipmentKeroToken.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class ShipmentKeroToken: NSObject {
    var token: String = ""
    var unixTime: Int = 0
    
    static func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: ["district_recommendation":"token", "ut":"unixTime"])
        return mapping
    }
}
