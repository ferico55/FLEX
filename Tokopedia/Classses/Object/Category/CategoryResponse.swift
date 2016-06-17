//
//  CategoryResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class CategoryResponse: NSObject,TKPObjectMapping {
    
    var status:String = ""
    var result:CategoryData = CategoryData(){
        didSet {
            data = result
        }
    }
    var data:CategoryData = CategoryData()
    
    @objc internal class func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status": "status"]
    }
    
    @objc internal class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "result", toKeyPath: "result", withMapping: CategoryData.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "data", withMapping: CategoryData.mapping()))
        
        return mapping
    }
    
}
