//
//  FilterResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterResponse: NSObject {

    var status : NSString = ""
    var data : FilterData = FilterData()
    
    
    class private func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status" : "status"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "data", withMapping: ListFilter.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
