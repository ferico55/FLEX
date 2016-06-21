//
//  FilterData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterData: NSObject {
    
    var filter : [ListFilter] = []
    var sort   : [ListOption] = []
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "filter", toKeyPath: "filter", withMapping: ListFilter.mapping())
        mapping.addPropertyMapping(relMapping)
        
        let relMappingSort : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "sort", toKeyPath: "sort", withMapping: ListOption.mapping())
        mapping.addPropertyMapping(relMappingSort)
        
        return mapping
    }

}
