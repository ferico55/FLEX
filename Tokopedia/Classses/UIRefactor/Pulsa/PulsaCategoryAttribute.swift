//
//  PulsaCategoryAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaCategoryAttribute: NSObject, NSCoding {
    var name : String = ""
    var weight : Int = 0
    var icon : String = ""
    var is_new : Bool = false
    var status : Int = 1
    var use_phonebook : Bool = false
    var validate_prefix : Bool = false
    var instant_checkout_available : Bool = false
    
    var client_number : PulsaCategoryClientNumber = PulsaCategoryClientNumber()

    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "name"  : "name",
            "weight" : "weight",
            "icon" : "icon",
            "is_new" : "is_new",
            "status" : "status",
            "use_phonebook" : "use_phonebook",
            "validate_prefix" : "validate_prefix",
            "instant_checkout_available" : "instant_checkout_available"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "client_number", toKeyPath: "client_number", withMapping: PulsaCategoryClientNumber.mapping())
        mapping.addPropertyMapping(relMapping)
        
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        
        if let weight = aDecoder.decodeObjectForKey("weight") as? Int {
            self.weight = weight
        }
        
        if let icon = aDecoder.decodeObjectForKey("icon") as? String {
            self.icon = icon
        }
        
        if let is_new = aDecoder.decodeObjectForKey("is_new") as? Bool {
            self.is_new = is_new
        }
        
        if let validate_prefix = aDecoder.decodeObjectForKey("validate_prefix") as? Bool {
            self.validate_prefix = validate_prefix
        }
        
        if let status = aDecoder.decodeObjectForKey("status") as? Int {
            self.status = status
        }
        
        if let use_phonebook = aDecoder.decodeObjectForKey("use_phonebook") as? Bool {
            self.use_phonebook = use_phonebook
        }
        
        if let instant_checkout_available = aDecoder.decodeObjectForKey("instant_checkout_available") as? Bool {
            self.instant_checkout_available = instant_checkout_available
        }
        
        if let client_number = aDecoder.decodeObjectForKey("client_number") as? PulsaCategoryClientNumber {
            self.client_number = client_number
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(weight, forKey: "weight")
        aCoder.encodeObject(icon, forKey: "icon")
        aCoder.encodeObject(is_new, forKey: "is_new")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(use_phonebook, forKey: "use_phonebook")
        aCoder.encodeObject(validate_prefix, forKey: "validate_prefix")
        aCoder.encodeObject(client_number, forKey: "client_number")
        aCoder.encodeObject(instant_checkout_available, forKey: "instant_checkout_available")
    }
}
