//
//  PulsaProductPromo.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaProductPromo: NSObject, NSCoding {
    var tag : String = ""
    var terms : String = ""
    var value_text : String = ""
    var bonus_text : String = ""
    var new_price : String = ""
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "tag"  : "tag",
            "terms" : "terms",
            "value_text" : "value_text",
            "bonus_text" : "bonus_text",
            "new_price" : "new_price",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let tag = aDecoder.decodeObject(forKey: "tag") as? String {
            self.tag = tag
        }
        
        if let terms = aDecoder.decodeObject(forKey: "terms") as? String {
            self.terms = terms
        }
        
        if let value_text = aDecoder.decodeObject(forKey: "value_text") as? String {
            self.value_text = value_text
        }
        
        if let bonus_text = aDecoder.decodeObject(forKey: "bonus_text") as? String {
            self.bonus_text = bonus_text
        }
        
        if let new_price = aDecoder.decodeObject(forKey: "new_price") as? String {
            self.new_price = new_price
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tag as Any?, forKey: "tag")
        aCoder.encode(terms as Any?, forKey: "terms")
        aCoder.encode(value_text as Any?, forKey: "value_text")
        aCoder.encode(bonus_text as Any?, forKey: "bonus_text")
        aCoder.encode(new_price as Any?, forKey: "new_price")
    }
}
