//
//  JSONAPIResultVoucher.swift
//  Tokopedia
//
//  Created by Ronald on 3/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class JSONAPIResultVoucher:NSObject {
    var type = ""
    var id = ""
    var attributes = DigitalCartVoucher()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["id", "type"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "attributes", toKeyPath: "attributes", with: DigitalCartVoucher.mapping()))
        return mapping
    }
}
