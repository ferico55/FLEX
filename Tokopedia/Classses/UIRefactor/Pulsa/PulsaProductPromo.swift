//
//  PulsaProductPromo.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProductPromo: NSObject, NSCoding {
    var tag : String = ""
    var terms : String = ""
    var value_text : String = ""
    var bonus_text : String = ""
    var new_price : Int = 1
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "tag"  : "tag",
            "terms" : "terms",
            "value_text" : "value_text",
            "bonus_text" : "bonus_text",
            "new_price" : "new_price",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let tag = aDecoder.decodeObjectForKey("tag") as? String {
            self.tag = tag
        }
        
        if let terms = aDecoder.decodeObjectForKey("terms") as? String {
            self.terms = terms
        }
        
        if let value_text = aDecoder.decodeObjectForKey("value_text") as? String {
            self.value_text = value_text
        }
        
        if let bonus_text = aDecoder.decodeObjectForKey("bonus_text") as? String {
            self.bonus_text = bonus_text
        }
        
        if let new_price = aDecoder.decodeObjectForKey("new_price") as? Int {
            self.new_price = new_price
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(tag, forKey: "tag")
        aCoder.encodeObject(terms, forKey: "terms")
        aCoder.encodeObject(value_text, forKey: "value_text")
        aCoder.encodeObject(bonus_text, forKey: "bonus_text")
        aCoder.encodeObject(new_price, forKey: "new_price")
    }
}
