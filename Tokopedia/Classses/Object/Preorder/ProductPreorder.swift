//
//  ProductPreorder.swift
//  Tokopedia
//
//  Created by atnlie on 12/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductPreorder: NSObject {
    var update_time = ""
    var order_limit = ""
    var create_time = ""
    var start_time  = ""
    var end_time    = ""
    var max_order   = ""
    var process_time_type_string = ""
    var process_day = 0
    var process_time_type = 0
    var process_time = 0
    lazy var isPreorder : Bool = {
        return (self.process_day>0) ? true : false
    }()

    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        mapping .addAttributeMappingsFromDictionary([
            "process_time_type_string"  : "process_time_type_string",
            "process_day"               : "process_day",
            "process_time_type"         : "process_time_type",
            "process_time"              : "process_time",
            "update_time"               : "update_time",
            "order_limit"               : "order_limit",
            "create_time"               : "create_time",
            "start_time"                : "start_time",
            "end_time"                  : "end_time",
            "max_order"                 : "max_order"
            ])
        return mapping
    }
}
