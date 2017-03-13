//
//  EnvelopeResponse.swift
//  Tokopedia
//
//  Created by Ronald on 2/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class EnvelopeResponse: NSObject {
    var message_error:[String] = []
    var header:EnvelopeHeader = EnvelopeHeader()
    var data:EnvelopeData = EnvelopeData()
    
    static func mapping(childMapping:RKObjectMapping) -> RKObjectMapping {
        let mapping:RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["header","message_error"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: EnvelopeData.mapping(childMapping: childMapping)))
        return mapping
    }
}
