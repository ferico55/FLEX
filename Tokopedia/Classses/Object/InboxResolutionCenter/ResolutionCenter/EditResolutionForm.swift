//
//  EditResolutionForm.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditResolutionForm : NSObject {
    
    var resolution_last     : ResolutionLast    = ResolutionLast()
    var resolution_order    : ResolutionOrder   = ResolutionOrder()
    var resolution_by       : ResolutionBy      = ResolutionBy()
    var resolution_customer : ResolutionCustomer = ResolutionCustomer()
    var resolution_solution_list : [EditSolution] = []
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "resolution_last",
            toKeyPath: "resolution_last",
            withMapping: ResolutionLast.mapping()))
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "resolution_order",
            toKeyPath: "resolution_order",
            withMapping: ResolutionOrder.mapping()))
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "resolution_by",
            toKeyPath: "resolution_by",
            withMapping: ResolutionBy.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "resolution_customer",
            toKeyPath: "resolution_customer",
            withMapping: ResolutionCustomer.mapping()))
        
        let relSolutionMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "resolution_solution_list",
                                                                                    toKeyPath: "resolution_solution_list",
                                                                                    withMapping: EditSolution.mapping())
        mapping.addPropertyMapping(relSolutionMapping)
        
        return mapping
    }

}
