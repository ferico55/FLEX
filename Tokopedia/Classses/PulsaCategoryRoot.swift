//
//  PulsaCategoryRoot.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaCategoryRoot: NSObject {
    var data : [PulsaCategory] = []
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "data", withMapping: PulsaCategory.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
