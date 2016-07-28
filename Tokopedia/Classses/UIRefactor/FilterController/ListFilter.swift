//
//  ListFilter.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ListFilter: NSObject, TKPObjectMapping {

    var title : String = ""
    var options : [ListOption] = []
    var search : searchObject = searchObject()
    var isActiveFilter : Bool = false
    var isMultipleSelect : Bool = true

    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["title" : "title"]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "options", toKeyPath: "options", withMapping: ListOption.mapping())
        mapping.addPropertyMapping(relMapping)
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "search", toKeyPath: "search", withMapping: searchObject.mapping()))
        
        return mapping
    }
    
}
