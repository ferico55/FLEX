//
//  EditResolutionFormData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditResolutionFormData: NSObject {
    
    var list_ts : [ResolutionCenterCreateList] = []
    var form    : EditResolutionForm = EditResolutionForm()
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "list_ts", toKeyPath: "list_ts", with: ResolutionCenterCreateList.mapping())
        mapping.addPropertyMapping(relMapping)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "form",
            toKeyPath: "form",
            with: EditResolutionForm.mapping()))
        
        return mapping
    }
}
