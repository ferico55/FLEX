//
//  EditResolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class EditResolution: NSObject {
    
    var message_error : [String] = []
    var status        : String = ""
    var data          : EditResolutionFormData = EditResolutionFormData()
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
            "message_error",
            "status"
            ])
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data",
            toKeyPath: "data",
            with: EditResolutionFormData.mapping()))
        
        return mapping
    }
}
