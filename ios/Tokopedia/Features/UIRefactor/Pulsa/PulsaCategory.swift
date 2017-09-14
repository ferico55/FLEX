//
//  PulsaCategory.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaCategory: NSObject, NSCoding {
    var id : String?
    var type : String?
    var attributes : PulsaCategoryAttribute = PulsaCategoryAttribute()
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "id"  : "id",
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "attributes", toKeyPath: "attributes", with: PulsaCategoryAttribute.mapping())
        mapping.addPropertyMapping(relMapping)
        
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
        
        if let attributes = aDecoder.decodeObject(forKey:"attributes") as? PulsaCategoryAttribute {
            self.attributes = attributes
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(attributes, forKey: "attributes")
    }
    
}
