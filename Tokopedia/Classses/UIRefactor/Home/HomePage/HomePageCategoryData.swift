//
//  HomePageCategory.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class HomePageCategoryData: NSObject{
    var layout_sections: [HomePageCategoryLayoutSection]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: HomePageCategoryData.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "layout_sections", toKeyPath: "layout_sections", withMapping: HomePageCategoryLayoutSection.mapping()))
        return mapping;
    }
}