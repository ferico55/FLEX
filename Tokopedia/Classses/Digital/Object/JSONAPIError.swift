//
//  JSONAPIError.swift
//  Tokopedia
//
//  Created by Ronald on 3/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class JSONAPIError:NSObject {
    var id = ""
    var status = ""
    var title = ""

    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["id", "status", "title"])
        return mapping
    }
}
