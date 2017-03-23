//
//  AnnouncementTicker.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class AnnouncementTicker: NSObject {
    var meta: GeneralMetaData!
    var data: AnnouncementTickerResult!
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        mapping!.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "meta", toKeyPath: "meta", with: GeneralMetaData.mapping()))
        
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: AnnouncementTickerResult.mapping()))
        
        return mapping
    }
}
