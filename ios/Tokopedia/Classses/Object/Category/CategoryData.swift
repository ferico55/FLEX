//
//  CategoryData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit
import Unbox

@objc class CategoryData: NSObject, Unboxable {
    
    var categories:[ListOption] = []

    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        let relMapping = RKRelationshipMapping(fromKeyPath: "categories", toKeyPath: "categories", with: ListOption.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    convenience required init(unboxer: Unboxer) throws {
        self.init()
        self.categories = try unboxer.unbox(keyPath: "categories")
    }
}
