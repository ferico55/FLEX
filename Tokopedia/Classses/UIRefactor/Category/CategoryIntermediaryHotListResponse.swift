//
//  CategoryIntermediaryHotListResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 4/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryHotListResponse: NSObject {
    
    var server_process_time: String!
    var list: [CategoryIntermediaryHotListItem]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryHotListResponse.self)
        mapping.addAttributeMappings(from:["server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "list", toKeyPath: "list", with: CategoryIntermediaryHotListItem.mapping()))
        return mapping;
    }
}

