//
//  PulsaOperatorAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaOperatorAttribute: NSObject, NSCoding {
    var name : String = ""
    var weight : Int = 0
    var image : String = ""
    var status : Int = 1
    var prefix: [String] = []
    var minimum_length: Int = 0
    // 14 is longest phone number existed
    var maximum_length: Int = 0
    var default_product_id : String = ""
    
    var rule: PulsaOperatorAttributeRule = PulsaOperatorAttributeRule()
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "name"  : "name",
            "weight" : "weight",
            "image" : "image",
            "status" : "status",
            "prefix" : "prefix",
            "minimum_length" : "minimum_length",
            "maximum_length" : "maximum_length",
            "default_product_id" : "default_product_id"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let ruleMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "rule", toKeyPath: "rule", with: PulsaOperatorAttributeRule.mapping())
        mapping.addPropertyMapping(ruleMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        }
        
        if let weight = aDecoder.decodeObject(forKey: "weight") as? Int {
            self.weight = weight
        }
        
        if let image = aDecoder.decodeObject(forKey: "image") as? String {
            self.image = image
        }
        
        if let minimum_length = aDecoder.decodeObject(forKey: "minimum_length") as? Int {
            self.minimum_length = minimum_length
        }
        
        if let maximum_length = aDecoder.decodeObject(forKey: "maximum_length") as? Int {
            self.maximum_length = maximum_length
        }
        
        if let status = aDecoder.decodeObject(forKey: "status") as? Int {
            self.status = status
        }
        
        if let prefix = aDecoder.decodeObject(forKey: "prefix") as? [String] {
            self.prefix = prefix
        }
        
        if let default_product_id = aDecoder.decodeObject(forKey: "default_product_id") as? String {
            self.default_product_id = default_product_id
        }
        
        if let rule = aDecoder.decodeObject(forKey:"rule") as? PulsaOperatorAttributeRule {
            self.rule = rule
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name as Any?, forKey: "name")
        aCoder.encode(weight as Any?, forKey: "weight")
        aCoder.encode(image as Any?, forKey: "image")
        aCoder.encode(status as Any?, forKey: "status")
        aCoder.encode(prefix as Any?, forKey: "prefix")
        aCoder.encode(minimum_length as Any?, forKey: "minimum_length")
        aCoder.encode(maximum_length as Any?, forKey: "maximum_length")
        aCoder.encode(default_product_id as Any?, forKey: "default_product_id")
        aCoder.encode(rule as Any?, forKey: "rule")
    }
}
