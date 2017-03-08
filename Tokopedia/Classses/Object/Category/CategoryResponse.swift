//
//  CategoryResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

@objc class CategoryResponse: NSObject {
    
    var status:String = ""
    var result:CategoryData = CategoryData(){
        didSet {
            data = result
        }
    }
    var data:CategoryData = CategoryData()
    
    fileprivate class func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["status": "status"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "result", toKeyPath: "result", with: CategoryData.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: CategoryData.mapping()))
        
        return mapping
    }
    
}
