//
//  PulsaStatus.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

class PulsaStatus: NSObject {
    var type : String!
    var attributes : PulsaStatusAttribute = PulsaStatusAttribute()
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "attributes", toKeyPath: "attributes", withMapping: PulsaStatusAttribute.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
