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
    var resolution_trouble_list : [ResolutionCenterCreateTroubleList] = []
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "resolution_last",
            toKeyPath: "resolution_last",
            with: ResolutionLast.mapping()))
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "resolution_order",
            toKeyPath: "resolution_order",
            with: ResolutionOrder.mapping()))
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "resolution_by",
            toKeyPath: "resolution_by",
            with: ResolutionBy.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "resolution_customer",
            toKeyPath: "resolution_customer",
            with: ResolutionCustomer.mapping()))
        
        let relSolutionMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "resolution_solution_list",
                                                                                    toKeyPath: "resolution_solution_list",
                                                                                    with: EditSolution.mapping())
        mapping.addPropertyMapping(relSolutionMapping)
        
        return mapping
    }

}
