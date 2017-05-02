//
//  CategoryIntermediaryChild.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RestKit

@objc(CategoryIntermediaryChild)
class CategoryIntermediaryChild: NSObject {
    
    var id: String = ""
    var name: String = ""
    var url: String = ""
    var thumbnailImage = ""
    var hidden: Int = 0
    // isRevamp digunakan sebagai penanda apakah category memiliki design sub category yang bergambar atau tidak
    var isRevamp: Bool = false
    // isIntermediary digunakan sebagai penanda apakah category termasuk intermediary atau bukan (memiliki hotlist, top editor choice, top ads toko)
    var isIntermediary: Bool = false
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryChild.self)
        mapping.addAttributeMappings(from:["id", "name", "url", "hidden"])
        mapping.addAttributeMappings(from: ["thumbnail_image" : "thumbnailImage",
                                            "is_revamp" : "isRevamp",
                                            "is_intermediary" : "isIntermediary"])
        return mapping;
    }
}
