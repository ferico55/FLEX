//
//  searchObject.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class searchObject: NSObject, TKPObjectMapping {
    
    var searchable : NSString = ""
    var placeholder : NSString = ""
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["searchable"   : "searchable",
                "placeholder"  : "placeholder"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: self.attributeMappingDictionary())
        
        return mapping
    }
}
