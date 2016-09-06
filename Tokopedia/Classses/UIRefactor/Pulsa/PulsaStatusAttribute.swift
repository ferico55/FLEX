//
//  PulsaStatusAttribbute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//


class PulsaStatusAttribute: NSObject {
    var is_maintenance : Bool = false
    
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "is_maintenance" : "is_maintenance",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        return mapping
    }
}
