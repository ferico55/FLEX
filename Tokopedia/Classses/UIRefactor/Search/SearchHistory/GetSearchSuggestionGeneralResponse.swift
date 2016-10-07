//
//  AdvancedSearchResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class GetSearchSuggestionGeneralResponse: NSObject {
    
    //var process_time: Double!
    var data: [SearchSuggestionData]!
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(forClass: GetSearchSuggestionGeneralResponse.self)
       // mapping.addAttributeMappingsFromArray(["process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: SearchSuggestionData.mapping()))
        return mapping;
    }
    
    
}