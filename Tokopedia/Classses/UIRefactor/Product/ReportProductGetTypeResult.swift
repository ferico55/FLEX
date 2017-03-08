//
//  ReportProductResult.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ReportProductGetTypeResult: NSObject {
    var is_success: String!
    var product_id: String!
    var list: [[String:NSObject]]!
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: ReportProductGetTypeResult.self)
        mapping?.addAttributeMappings(from:["is_success", "product_id", "list"])
        return mapping!
    }
}
