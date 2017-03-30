//
//  CategoryIntermediaryChild.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

class CategoryIntermediaryResult: NSObject {
    var children: [CategoryIntermediaryChild]!
    var id: String = ""
    var name: String = ""
    var categoryDescription: String = ""
    var titleTag: String = ""
    var metaDescription: String = ""
    var headerImage: String = ""
    var hidden: Int = 0
    // views digunakan untuk penanda apakah list produk dari intermediary ditampilkan secara grid, list, atau one
    var views: Int = 0
    var isRevamp: Bool = false
    var isIntermediary: Bool = false
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryResult.self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "child", toKeyPath: "children", with: CategoryIntermediaryChild.mapping()))
        mapping.addAttributeMappings(from: ["id", "name", "hidden"])
        mapping.addAttributeMappings(from:["description" : "categoryDescription",
                                           "title_tag" : "titleTag",
                                           "meta_description" : "metaDescription",
                                           "header_image" : "headerImage",
                                           "view" : "views",
                                           "is_revamp" : "isRevamp",
                                           "is_intermediary" : "isIntermediary"])
        return mapping;
    }
}
