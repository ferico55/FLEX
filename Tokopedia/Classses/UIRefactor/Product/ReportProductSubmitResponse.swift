//
//  ReportProductSubmitResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductSubmitResponse: NSObject {
    var status: String!
    var server_process_time: String!
    var data: ReportProductSubmitResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: ReportProductSubmitResponse.self)
        mapping.addAttributeMappingsFromArray(["status", "server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: ReportProductSubmitResult.mapping()))
        return mapping;
    }

    
}
