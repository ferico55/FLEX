//
//  HomePageCategoryResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 10/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class HomePageCategoryResponse: NSObject {
    var headers: [String : String]!
    var data: HomePageCategoryData!
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: HomePageCategoryResponse.self)
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: HomePageCategoryData.mapping()))
        return mapping!
    }
}
