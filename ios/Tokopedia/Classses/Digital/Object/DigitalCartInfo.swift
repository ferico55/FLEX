//
//  DigitalCartInfo.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class DigitalCartInfo:NSObject {
    var title = ""
    var detail = [DigitalCartInfoDetail]()
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["title"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "detail", toKeyPath: "detail", with:DigitalCartInfoDetail.mapping()))
        return mapping
    }
}
