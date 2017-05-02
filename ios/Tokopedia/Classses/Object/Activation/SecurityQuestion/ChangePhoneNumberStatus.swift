//
//  ChangePhoneNumberStatus.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ChangePhoneNumberStatus: NSObject {
    var isSuccess: Bool = false
    var is_success: String = String() {
        didSet {
            self.isSuccess = (is_success == "1")
        }
    }
    
    var isPending: Bool = false
    var is_pending: String = String() {
        didSet {
            self.isPending = (is_pending == "1")
        }
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "is_success",
            "is_pending"
            ])
        
        return mapping!
    }
}
