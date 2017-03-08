//
//  DetailProductVideoArray.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

@objc(DetailProductVideo)
class DetailProductVideo: NSObject {
    var url: String = ""
    var type: String = ""
    var varDefault: Int!
    var status: NSNumber! {
        didSet {
            if status == 1 {
                banned = false
            }
        }
    }
    var banned: Bool = true
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: DetailProductVideo.self)
        
        mapping?.addAttributeMappings(from:["varDefault" : "default"])
        mapping?.addAttributeMappings(from: ["url", "type", "status"])
        
        return mapping!
    }
}
