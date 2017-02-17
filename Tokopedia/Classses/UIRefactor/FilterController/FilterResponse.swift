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
    
    
    class fileprivate func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["status" : "status"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: FilterData.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
