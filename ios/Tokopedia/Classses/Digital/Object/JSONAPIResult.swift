//
//  JSONAPIResult.swift
//  Tokopedia
//
//  Created by Ronald on 3/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class JSONAPIResult:NSObject {
    var type = ""
    var id = ""
    var attributes = DigitalCart()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["id", "type"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "attributes", toKeyPath: "attributes", with: DigitalCart.mapping()))
        return mapping
    }
}
