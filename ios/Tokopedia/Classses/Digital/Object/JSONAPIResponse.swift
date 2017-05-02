//
//  JSONAPIResponse.swift
//  Tokopedia
//
//  Created by Ronald on 3/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class JSONAPIResponse:NSObject {
    var data = JSONAPIResult()
    var error = JSONAPIError()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "errors", toKeyPath: "error", with: JSONAPIResult.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: JSONAPIResult.mapping()))
        return mapping
    }
}
