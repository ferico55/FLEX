//
//  AnnouncementTickerResult.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTickerResult: NSObject {
    var tickers: [AnnouncementTickerObject] = []
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        
        mapping?.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "tickers", toKeyPath: "tickers", with: AnnouncementTickerObject.mapping()))
        
        return mapping
    }
}
