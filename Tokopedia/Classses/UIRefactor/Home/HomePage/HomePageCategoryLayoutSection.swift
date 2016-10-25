//
//  HomePageCategoryLayoutSection.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class HomePageCategoryLayoutSection: NSObject {
    var id: String!
    var title: String!
    var layout_rows: [HomePageCategoryLayoutRow]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: HomePageCategoryLayoutSection.self)
        mapping.addAttributeMappingsFromArray(["id", "title"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "layout_rows", toKeyPath: "layout_rows", withMapping: HomePageCategoryLayoutRow.mapping()))
        
        return mapping
    }
}