//
//  EditResolutionFormData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditResolutionFormData: NSObject {
    
    var list_ts : [ResolutionTroubleSolution] = []
    var form    : EditResolutionFormData    = EditResolutionFormData()
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "list_ts", toKeyPath: "list_ts", withMapping: ResolutionTroubleSolution.mapping())
        mapping.addPropertyMapping(relMapping)
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "form",
            toKeyPath: "form",
            withMapping: ResolutionTroubleSolution.mapping()))
        
        return mapping
    }
}
