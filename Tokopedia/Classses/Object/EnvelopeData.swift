//
//  EnvelopeData.swift
//  Tokopedia
//
//  Created by Ronald on 2/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

class EnvelopeData:NSObject {
    var list = [AnyObject]()
    
    static func mapping(childMapping:RKMapping) -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addRelationshipMapping(withSourceKeyPath: "list", mapping: childMapping)
        return mapping
    }
}
