//
//  JSONAPIResponseVoucher.swift
//  Tokopedia
//
//  Created by Ronald on 3/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class JSONAPIResponseVoucher:NSObject {
    var data = JSONAPIResultVoucher()
    var error = [JSONAPIError]()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["error"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: JSONAPIResultVoucher.mapping()))
        return mapping
    }
}
