//
//  CategoryIntermediaryHotListImage.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListImage: NSObject {
    
    var url: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListImage.self)
        mapping.addAttributeMappings(from:["375x200" : "url"])
        return mapping;
    }
    
}
