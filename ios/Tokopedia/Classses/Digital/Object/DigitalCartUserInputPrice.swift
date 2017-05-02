//
//  DigitalCartUserInfoPrice.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class DigitalCartUserInputPrice:NSObject {
    var max:Double = 0
    var min:Double = 0
    var maxText = ""
    var minText = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["max_payment_plain":"max","min_payment_plain":"min","max_payment":"maxText","min_payment":"minText"])
        return mapping
    }
}
