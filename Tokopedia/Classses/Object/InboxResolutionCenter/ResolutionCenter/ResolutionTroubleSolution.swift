//
//  ResolutionTroubleSolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ResolutionTroubleSolution: NSObject {
    
    var attachment          : String = ""
    var product_is_received : String = ""
    var product_related     : String = ""
    var trouble_list        : [ResolutionCenterCreateTroubleList] = []
    var possible_solution   : [ResolutionCenterCreateSolutionList] = []
    var category_trouble_id : String = ""
    var category_trouble_text : String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromArray([
            "attachment",
            "product_is_received",
            "product_related",
            "category_trouble_id",
            "category_trouble_text"
            ])
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "trouble_list", toKeyPath: "trouble_list", withMapping: ResolutionCenterCreateTroubleList.mapping())
        mapping.addPropertyMapping(relMapping)
        
        let relSolutionMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "possible_solution", toKeyPath: "possible_solution", withMapping: ResolutionCenterCreateSolutionList.mapping())
        mapping.addPropertyMapping(relSolutionMapping)
        
        return mapping
    }

}
