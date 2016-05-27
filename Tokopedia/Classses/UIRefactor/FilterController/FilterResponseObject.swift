//
//  FilterResponseObject.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterResponseObject: NSObject , TKPObjectMapping{
    
    var status : String = ""
    var list : [FilterObject] = []
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status" : "status"]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping = RKRelationshipMapping.init(fromKeyPath: "list", toKeyPath: "list", withMapping: FilterObject .mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }

}