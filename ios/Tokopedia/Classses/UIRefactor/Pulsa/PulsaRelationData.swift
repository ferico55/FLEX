//
//  PulsaRelationData.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaRelationData: NSObject {
    var id : String?
    var type : String?
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "id"  : "id",
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let id = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = id
        }
        
        if let type = aDecoder.decodeObject(forKey: "type") as? String {
            self.type = type
        }

    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(id as Any?, forKey: "id")
        aCoder.encode(type as Any?, forKey: "type")
    }
}
