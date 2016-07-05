//
//  PulsaCategoryAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaCategoryAttribute: NSObject {
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
}
