//
//  PulsaRelationCategory.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaRelationCategory: NSObject {
    var data : PulsaRelationData = PulsaRelationData()
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: PulsaRelationData.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(forKey:"data") as? PulsaRelationData {
            self.data = data
        }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(data as Any?, forKey: "data")
    }
}
