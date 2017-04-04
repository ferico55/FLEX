//
//  CategoryIntermediaryResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryResponse: NSObject {
    
    var server_process_time: String!
    var result: CategoryIntermediaryResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryResponse.self)
        mapping.addAttributeMappings(from:["server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "result", toKeyPath: "result", with: CategoryIntermediaryResult.mapping()))
        return mapping;
    }

}
