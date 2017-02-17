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
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "filter", toKeyPath: "filter", with: ListFilter.mapping())
        mapping.addPropertyMapping(relMapping)
        
        let relMappingSort : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "sort", toKeyPath: "sort", with: ListOption.mapping())
        mapping.addPropertyMapping(relMappingSort)
        
        return mapping
    }

}
