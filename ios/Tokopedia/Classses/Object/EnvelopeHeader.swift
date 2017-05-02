//
//  EnvelopeHeader.swift
//  Tokopedia
//
//  Created by Ronald on 2/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class EnvelopeHeader:NSObject {
    var total_data = ""
    var server_process_time = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:[
            "total_data" : "total_data",
            "server_process_time" : "server_process_time"
            ])
        
        return mapping
    }
}
