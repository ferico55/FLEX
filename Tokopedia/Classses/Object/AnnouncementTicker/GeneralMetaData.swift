//
//  AnnouncementTickerMeta.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class GeneralMetaData: NSObject {
    var total_data: String = ""
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        
        mapping?.addAttributeMappings(from:["total_data"])
        
        return mapping
    }
}
