//
//  ReportProductResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductGetTypeResponse: NSObject {
    
    var status: String!
    var server_process_time: String!
    var data: ReportProductGetTypeResult!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: ReportProductGetTypeResponse.self)
        mapping.addAttributeMappings(from:["status", "server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: ReportProductGetTypeResult.mapping()))
        return mapping;
    }
}
