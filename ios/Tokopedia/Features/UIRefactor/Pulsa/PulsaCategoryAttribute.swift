//
//  PulsaCategoryAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaCategoryAttribute: NSObject, NSCoding {
    var name : String = ""
    var weight : Int = 0
    var icon : String = ""
    var is_new : Bool = false
    var status : Int = 1
    var use_phonebook : Bool = false
    var show_operator : Bool = false
    var validate_prefix : Bool = false
    var instant_checkout_available : Bool = false
    var default_operator_id : String = ""
    
    var client_number : PulsaCategoryClientNumber = PulsaCategoryClientNumber()
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "name"  : "name",
            "weight" : "weight",
            "icon" : "icon",
            "is_new" : "is_new",
            "status" : "status",
            "use_phonebook" : "use_phonebook",
            "show_operator" : "show_operator",
            "validate_prefix" : "validate_prefix",
            "default_operator_id" : "default_operator_id",
            "instant_checkout_available" : "instant_checkout_available"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "client_number", toKeyPath: "client_number", with: PulsaCategoryClientNumber.mapping())
        mapping.addPropertyMapping(relMapping)
        
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
        
        if let icon = aDecoder.decodeObject(forKey: "icon") as? String {
            self.icon = icon
        }
        
        if let is_new = aDecoder.decodeObject(forKey: "is_new") as? Bool {
            self.is_new = is_new
        }
        
        if let validate_prefix = aDecoder.decodeObject(forKey: "validate_prefix") as? Bool {
            self.validate_prefix = validate_prefix
        }
        
        if let status = aDecoder.decodeObject(forKey: "status") as? Int {
            self.status = status
        }
        
        if let use_phonebook = aDecoder.decodeObject(forKey: "use_phonebook") as? Bool {
            self.use_phonebook = use_phonebook
        }
        
        if let show_operator = aDecoder.decodeObject(forKey: "show_operator") as? Bool {
            self.show_operator = show_operator
        }
        
        if let default_operator_id = aDecoder.decodeObject(forKey: "default_operator_id") as? String {
            self.default_operator_id = default_operator_id
        }
        
        if let instant_checkout_available = aDecoder.decodeObject(forKey: "instant_checkout_available") as? Bool {
            self.instant_checkout_available = instant_checkout_available
        }
        
        if let client_number = aDecoder.decodeObject(forKey:"client_number") as? PulsaCategoryClientNumber {
            self.client_number = client_number
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name  as Any?, forKey: "name")
        aCoder.encode(weight  as Any?, forKey: "weight")
        aCoder.encode(icon  as Any?, forKey: "icon")
        aCoder.encode(is_new  as Any?, forKey: "is_new")
        aCoder.encode(status  as Any?, forKey: "status")
        aCoder.encode(use_phonebook  as Any?, forKey: "use_phonebook")
        aCoder.encode(show_operator  as Any?, forKey: "show_operator")
        aCoder.encode(validate_prefix  as Any?, forKey: "validate_prefix")
        aCoder.encode(default_operator_id  as Any?, forKey: "default_operator_id")
        aCoder.encode(client_number  as Any?, forKey: "client_number")
        aCoder.encode(instant_checkout_available  as Any?, forKey: "instant_checkout_available")
    }
}
