//
//  EditResolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditResolution: NSObject {
    
    var message_error : [String] = []
    var status        : String = ""
    var data          : EditResolutionFormData = EditResolutionFormData()
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromArray([
            "message_error",
            "status"
            ])
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "data",
            toKeyPath: "data",
            withMapping: EditResolutionFormData.mapping()))
        
        return mapping
    }
}
