//
//  CategoryIntermediaryHotListImage.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListImage: NSObject {
    
    var url: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListImage.self)
        mapping.addAttributeMappings(from:["280x418" : "url"])
        return mapping;
    }

}
