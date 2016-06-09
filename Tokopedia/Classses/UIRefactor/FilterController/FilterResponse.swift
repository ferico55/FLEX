//
//  FilterResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterResponse: NSObject, TKPObjectMapping {

    var status : NSString = ""
    var filter : [ListFilter] = []
    var sort   : [ListOption] = []
    
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status" : "status"]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "filter", toKeyPath: "filter", withMapping: ListFilter.mapping())
        mapping.addPropertyMapping(relMapping)
        
        let relMappingSort : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "sort", toKeyPath: "sort", withMapping: ListOption.mapping())
        mapping.addPropertyMapping(relMappingSort)
        
        return mapping
    }
}
