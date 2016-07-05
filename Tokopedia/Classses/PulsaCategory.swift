//
//  PulsaCategory.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaCategory: NSObject {
    var id : String = ""
    var type : String = ""
    var attributes : PulsaCategoryAttribute = PulsaCategoryAttribute()
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "id"  : "id",
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "attributes", toKeyPath: "attributes", withMapping: PulsaCategoryAttribute.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
