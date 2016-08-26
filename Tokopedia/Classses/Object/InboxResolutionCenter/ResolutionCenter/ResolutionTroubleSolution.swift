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
    //TODO:: LIST TROUBLE
    var category_trouble_id : String = ""
    var category_trouble_text : String = ""
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addPropertyMappingsFromArray([
            "attachment",
            "product_is_received",
            "product_related",
            "category_trouble_id",
            "category_trouble_text"
            ])
        
        return mapping
    }

}
