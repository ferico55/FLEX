//
//  DigitalCartInfoDetail.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class DigitalCartInfoDetail:Unboxable {
    var label = ""
    var value = ""
    
    init(label:String, value:String) {
        self.label = label
        self.value = value
    }
    
    convenience init(unboxer:Unboxer) throws {
        let label = try unboxer.unbox(keyPath: "label") as String
        let value = try unboxer.unbox(keyPath: "value") as String
        
        self.init(label:label, value:value)
    }
}
