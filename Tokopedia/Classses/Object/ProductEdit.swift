//
//  ProductEdit.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductEdit: NSObject {
    var status: String = ""
    var result: ProductEditResult!
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary(["status" : "status"])

        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "result", toKeyPath: "result", withMapping: ProductEditResult.mapping()))
        
        return mapping
    }
}
