//
//  PulsaOperatorRoot.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaOperatorRoot: NSObject, NSCoding {
    var data : [PulsaOperator] = []
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "data", withMapping: PulsaOperator.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let data = aDecoder.decodeObjectForKey("data") as? [PulsaOperator] {
            self.data = data
        }
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(data, forKey: "data")
    }
}
