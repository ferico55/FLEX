//
//  ProductReturnInfo.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ProductReturnInfo: NSObject {
    var icon: String = ""
    var color_rgb: String = ""
    var content: String = ""
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: ["icon" : "icon", "color_rgb" : "color_rgb", "content" : "content"])
        
        return mapping
    }

}
