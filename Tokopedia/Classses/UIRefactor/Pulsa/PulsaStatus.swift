//
//  PulsaStatus.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import RestKit

class PulsaStatus: NSObject {
    var type : String!
    var attributes : PulsaStatusAttribute = PulsaStatusAttribute()
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "attributes", toKeyPath: "attributes", with: PulsaStatusAttribute.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
