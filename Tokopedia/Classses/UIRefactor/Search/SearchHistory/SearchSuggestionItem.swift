//
//  AdvancedSearchItem.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class SearchSuggestionItem: NSObject {
    var keyword = ""
    var url = ""
    var redirectUrl = ""
    var imageURI = ""
    var isOfficial = false
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: SearchSuggestionItem.self)
        mapping.addAttributeMappingsFromArray(["keyword", "url", "imageURI", "isOfficial"])
        mapping.addAttributeMappingsFromDictionary(["redirection_url":"redirectUrl"])
        return mapping
    }
}
