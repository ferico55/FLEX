//
//  ListOption.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ListOption: NSObject, TKPObjectMapping, NSCopying {
    
    var name : String = ""
    var value : String = ""
    var key : String = ""
    var input_type : String = ""
    var isSelected : Bool = false
    
    required override init() {
    }
    
    required init(_ model: ListOption) {
        name = model.name
        key = model.key
        input_type = model.input_type
        value = model.value
        isSelected = model.isSelected
    }
    
    func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(self)
    }
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "name"  : "name",
            "value" : "value",
            "key"   : "key",
            "input_type"  : "input_type"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: self.attributeMappingDictionary())
                
        return mapping
    }

}
