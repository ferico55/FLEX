//
//  PulsaRelationData.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaRelationData: NSObject {
    var id : String?
    var type : String?
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "id"  : "id",
            "type" : "type",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
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

    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(type, forKey: "type")
    }
}
