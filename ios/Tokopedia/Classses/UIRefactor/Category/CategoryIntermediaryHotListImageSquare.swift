//
//  CategoryIntermediaryHotListImageSquare.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListImageSquare: NSObject {
    
    var url: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListImageSquare.self)
        mapping.addAttributeMappings(from:["200x200" : "url"])
        return mapping;
    }
    
}
