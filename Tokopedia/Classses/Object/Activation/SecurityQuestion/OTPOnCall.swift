//
//  OTPOnCall.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class OTPOnCall: NSObject {
    var otpSent: Bool = false
    
    class func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "otp_sent" : "otpSent"
            ])
        
        return mapping!
    }
}
