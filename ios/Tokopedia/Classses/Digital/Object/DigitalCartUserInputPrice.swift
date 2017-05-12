//
//  DigitalCartUserInfoPrice.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class DigitalCartUserInputPrice:Unboxable {
    var max:Double = 0
    var min:Double = 0
    var maxText = ""
    var minText = ""
    
    init(max:Double, min:Double, maxText:String, minText:String) {
        self.max = max
        self.min = min
        self.maxText = maxText
        self.minText = minText
    }
    
    convenience init(unboxer:Unboxer) throws {
        let max = try unboxer.unbox(keyPath: "max_payment_plain") as Double
        let min = try unboxer.unbox(keyPath: "min_payment_plain") as Double
        let maxText = try unboxer.unbox(keyPath: "max_payment") as String
        let minText = try unboxer.unbox(keyPath: "min_payment") as String
        
        self.init(max:max, min:min, maxText:maxText, minText:minText)
    }
}
