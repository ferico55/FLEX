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
    
    fileprivate class func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return nil
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        let relMapping = RKRelationshipMapping(fromKeyPath: "categories", toKeyPath: "categories", with: CategoryDetail.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
}
