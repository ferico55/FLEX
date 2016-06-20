//
//  CategoryData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class CategoryData: NSObject {
    
    var categories:[CategoryDetail] = []
    
    private class func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return nil
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        let relMapping = RKRelationshipMapping.init(fromKeyPath: "categories", toKeyPath: "categories", withMapping: CategoryDetail.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
