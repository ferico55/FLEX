//
//  ProductEditInfo.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductEditInfo: NSObject {
    var shop_has_terms: String = ""
    var product_returnable: String = "0"
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping .addAttributeMappings(from:["shop_has_terms" : "shop_has_terms", "product_returnable" : "product_returnable"])
        
        return mapping
    }
}
