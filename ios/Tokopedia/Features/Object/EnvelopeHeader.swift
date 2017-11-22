//
//  EnvelopeHeader.swift
//  Tokopedia
//
//  Created by Ronald on 2/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class EnvelopeHeader:NSObject, Unboxable {
    var total_data = ""
    var server_process_time = ""
    var additional_params: String?
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:[
            "total_data" : "total_data",
            "server_process_time" : "server_process_time",
            "additional_params" : "additional_params"
            ])
        
        return mapping
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init()
        self.total_data = try unboxer.unbox(keyPath: "total_data")
        self.server_process_time = try unboxer.unbox(keyPath: "process_time")
        self.additional_params = try?  unboxer.unbox(keyPath: "additional_params")
        
    }
}
