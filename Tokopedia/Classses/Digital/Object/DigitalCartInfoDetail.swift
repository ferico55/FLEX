//
//  DigitalCartInfoDetail.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class DigitalCartInfoDetail:NSObject {
    var label = ""
    var value = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["label","value"])
        return mapping
    }
}
