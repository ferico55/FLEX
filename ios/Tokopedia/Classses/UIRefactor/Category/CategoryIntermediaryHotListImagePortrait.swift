//
//  CategoryIntermediaryHotListImagePortrait.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListImagePortrait: NSObject {
    
    var url: String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListImagePortrait.self)
        mapping.addAttributeMappings(from:["280x418" : "url"])
        return mapping;
    }

}
