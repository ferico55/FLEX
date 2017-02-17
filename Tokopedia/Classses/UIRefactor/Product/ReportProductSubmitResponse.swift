//
//  ReportProductSubmitResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductSubmitResponse: NSObject {
    
    var message_error: [String]!
    var status: String!
    var server_process_time: String!
    var data: ReportProductSubmitResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: ReportProductSubmitResponse.self)
        mapping.addAttributeMappings(from:["message_error", "status", "server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: ReportProductSubmitResult.mapping()))
        return mapping;
    }

    
}
