//
//  PulsaStatusRoot.swift
//  Tokopedia
//
//  Created by Tonito Acen on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//
import RestKit

class PulsaStatusRoot: NSObject {
    var data : PulsaStatus!
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: PulsaStatus.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
