//
//  PulsaStatusRoot.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//


class PulsaStatusRoot: NSObject {
    var data : PulsaStatus!
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "data", withMapping: PulsaStatus.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
