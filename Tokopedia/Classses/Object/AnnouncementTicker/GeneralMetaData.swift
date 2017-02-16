//
//  AnnouncementTickerMeta.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class GeneralMetaData: NSObject {
    var total_data: String = ""
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(forClass: self)
        
        mapping.addAttributeMappingsFromArray(["total_data"])
        
        return mapping
    }
}
