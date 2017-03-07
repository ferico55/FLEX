//
//  ReportProductSubmitResult.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ReportProductSubmitResult: NSObject {
    var is_success: String!
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: ReportProductSubmitResult.self)
        mapping?.addAttributeMappings(from:["is_success"])
        return mapping!
    }

}
