//
//  PulsaOperatorAttributeRule.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaOperatorAttributeRule: NSObject {

    var product_text : String?
    var show_price : Bool = false
    var show_product : Bool = false
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "product_text"  : "product_text",
            "show_price" : "show_price",
            "show_product" : "show_product"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: self.attributeMappingDictionary())

        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let product_text = aDecoder.decodeObject(forKey: "product_text") as? String {
            self.product_text = product_text
        }
        
        if let show_price = aDecoder.decodeObject(forKey: "show_price") as? Bool {
            self.show_price = show_price
        }
        
        if let show_product = aDecoder.decodeObject(forKey: "show_product") as? Bool {
            self.show_product = show_product
        }
    }
    
    func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(product_text as Any?, forKey: "product_text")
        aCoder.encode(show_price as Any?, forKey: "show_price")
        aCoder.encode(show_product as Any?, forKey: "show_product")
    }
}
