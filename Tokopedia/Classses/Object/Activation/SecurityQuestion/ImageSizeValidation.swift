//
//  ImageSizeValidation.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ImageSizeValidation: NSObject {
    var isSuccess: Bool = false
    var is_success: String = String() {
        didSet {
            self.isSuccess = (is_success == "1")
        }
    }
    
    var token: String = ""
    
    class func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "is_success",
            "token"
            ])
        
        return mapping!
    }
}

