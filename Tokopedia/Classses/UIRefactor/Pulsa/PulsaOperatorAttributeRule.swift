//
//  PulsaOperatorAttributeRule.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaOperatorAttributeRule: NSObject {

    var product_text : String?
    var show_price : Bool = false
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "product_text"  : "product_text",
            "show_price" : "show_price",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())

        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let product_text = aDecoder.decodeObjectForKey("product_text") as? String {
            self.product_text = product_text
        }
        
        if let show_price = aDecoder.decodeObjectForKey("show_price") as? Bool {
            self.show_price = show_price
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(product_text, forKey: "product_text")
        aCoder.encodeObject(show_price, forKey: "show_price")
        
    }
}
