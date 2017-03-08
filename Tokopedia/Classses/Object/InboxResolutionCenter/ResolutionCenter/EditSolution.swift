//
//  EditSolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class EditSolution: NSObject {
    var refund_text_desc : String = ""
    var show_refund_box : String = ""
    var refund_type : String = ""
    var max_refund_idr : String = ""
    var solution_text : String = ""
    var solution_id : String = ""
    var max_refund : String = ""
    var refund_amt_idr : String = ""
    var refund_amt : String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
                "refund_text_desc",
                "show_refund_box",
                "refund_type",
                "max_refund_idr",
                "solution_text",
                "solution_id",
                "max_refund"
            ])
        
        return mapping
    }
}
