//
//  AdvancedSearchDataResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class SearchSuggestionData: NSObject {
    var name = ""
    var id = ""
    var items: [SearchSuggestionItem]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: SearchSuggestionData.self)
        mapping.addAttributeMappingsFromArray(["name", "id"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "items", toKeyPath: "items", withMapping: SearchSuggestionItem.mapping()))
        return mapping
    }
}
