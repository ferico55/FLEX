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

    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "name"  : "name",
            "weight" : "weight",
            "icon" : "icon",
            "is_new" : "is_new",
            "status" : "status",
            "use_phonebook" : "use_phonebook",
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
        
        if let status = aDecoder.decodeObjectForKey("status") as? Int {
            self.status = status
        }
        
        if let use_phonebook = aDecoder.decodeObjectForKey("use_phonebook") as? Bool {
            self.use_phonebook = use_phonebook
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(weight, forKey: "weight")
        aCoder.encodeObject(icon, forKey: "icon")
        aCoder.encodeObject(is_new, forKey: "is_new")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(use_phonebook, forKey: "use_phonebook")
    }
}
