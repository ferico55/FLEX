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

    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["title" : "title"]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "options", toKeyPath: "options", with: ListOption.mapping())
        mapping.addPropertyMapping(relMapping)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "search", toKeyPath: "search", with: searchObject.mapping()))
        
        return mapping
    }
    
}
