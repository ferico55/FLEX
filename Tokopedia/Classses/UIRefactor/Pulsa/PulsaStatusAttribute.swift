//
//  PulsaStatusAttribbute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//


class PulsaStatusAttribute: NSObject {
    var is_maintenance : Bool = false
    
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "is_maintenance" : "is_maintenance",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        return mapping
    }
}
