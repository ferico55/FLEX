//
//  UserInfo.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 6/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(AccountInfo)
class AccountInfo: NSObject {
    var userId: String!
    var createdPassword: Bool = false
    var email = ""
    var name = ""


    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "user_id": "userId",
            "created_password": "createdPassword",
            "email":"email",
            "name":"name"
        ])
        
        return mapping
    }
}
