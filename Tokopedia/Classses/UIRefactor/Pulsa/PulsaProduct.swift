//
//  PulsaProduct.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProduct: NSObject, NSCoding {
    var id : String?
    var type : String?
    var attributes : PulsaProductAttribute = PulsaProductAttribute()
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "id"  : "id",
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "attributes", toKeyPath: "attributes", withMapping: PulsaProductAttribute.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let id = aDecoder.decodeObjectForKey("id") as? String {
            self.id = id
        }
        
        if let type = aDecoder.decodeObjectForKey("type") as? String {
            self.type = type
        }
        
        if let attributes = aDecoder.decodeObjectForKey("attributes") as? PulsaProductAttribute {
            self.attributes = attributes
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(type, forKey: "type")
        aCoder.encodeObject(attributes, forKey: "attributes")
    }

}
