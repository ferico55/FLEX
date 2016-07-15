//
//  ReportProductResult.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReportProductResult: NSObject {
    var is_success: String!
    var product_id: String!
    var list: [[String:NSObject]]!
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(forClass: ReportProductResult.self)
        mapping.addAttributeMappingsFromArray(["is_success", "product_id", "list"])
        return mapping
    }
}
