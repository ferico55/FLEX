//
//  ListOption.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ListOption: NSObject, TKPObjectMapping, NSCopying {
    
    var name : String = ""
    var value : String = ""
    var key : String = ""
    var type : String = ""
    var isSelected : Bool = false
    
    required override init() {
    }
    
    required init(_ model: ListOption) {
        name = model.name
        key = model.key
        type = model.type
        value = model.value
        isSelected = model.isSelected
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "name"  : "name",
            "value" : "value",
            "key"   : "key",
            "type"  : "type"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
                
        return mapping
    }

}
