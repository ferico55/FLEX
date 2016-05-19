//
//  CategoryData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class CategoryData: NSObject, TKPObjectMapping {
    
    var categories:[CategoryDetail] = []
    
    @objc internal class func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return nil
    }
    
    @objc internal class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        let relMapping = RKRelationshipMapping.init(fromKeyPath: "categories", toKeyPath: "categories", withMapping: CategoryDetail.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
