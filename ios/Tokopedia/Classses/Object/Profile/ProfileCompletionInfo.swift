//
//  ProfileCompletionInfo.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class ProfileCompletionInfo: NSObject {
    var gender: Int = 3
    var phoneVerified: Bool = false
    var bday: String = ""
    var completion: Int = 0
    
    static func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
            "gender":"gender", "phone_verified":"phoneVerified", "bday":"bday", "completion":"completion"
            ])
        return mapping
    }
}
