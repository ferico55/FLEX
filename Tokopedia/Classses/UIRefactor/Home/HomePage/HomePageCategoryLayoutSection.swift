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
        let mapping: RKObjectMapping = RKObjectMapping(for: HomePageCategoryLayoutSection.self)
        mapping.addAttributeMappings(from:["id", "title"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "layout_rows", toKeyPath: "layout_rows", with: HomePageCategoryLayoutRow.mapping()))
        
        return mapping
    }
}
