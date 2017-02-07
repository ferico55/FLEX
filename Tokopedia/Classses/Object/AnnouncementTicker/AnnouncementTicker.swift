//
//  AnnouncementTicker.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTicker: NSObject {
    var meta: GeneralMetaData!
    var data: AnnouncementTickerResult!
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(forClass: self)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "meta", toKeyPath: "meta", withMapping: GeneralMetaData.mapping()))
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: AnnouncementTickerResult.mapping()))
        
        return mapping
    }
}
