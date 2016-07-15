//
//  ReportProductResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductResponse: NSObject {
    
    var status: String!
    var server_process_time: String!
    var data: ReportProductResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: ReportProductResponse.self)
        mapping.addAttributeMappingsFromArray(["status", "server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: ReportProductResult.mapping()))
        return mapping;
    }
}
