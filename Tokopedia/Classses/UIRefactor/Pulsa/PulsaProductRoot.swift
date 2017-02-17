//
//  PulsaProductRoot.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProductRoot: NSObject, NSCoding {
    var data : [PulsaProduct] = []
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: PulsaProduct.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(forKey: "data") as? [PulsaProduct] {
            self.data = data
        }
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(data, forKey: "data")
    }
}
