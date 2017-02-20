//
//  DiscoverResponse.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class DiscoverResponse: NSObject {
    var message_error: [String]!
    var status: String!
    var server_process_time: String!
    var data: DiscoverResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "message_error": "message_error",
            "status": "status"
        ])
        
        let relationshipMapping = RKRelationshipMapping(
            fromKeyPath: "data",
            toKeyPath: "data",
            with: DiscoverResult.mapping())
        
        mapping?.addPropertyMapping(relationshipMapping)
        
        return mapping!
    }
}
