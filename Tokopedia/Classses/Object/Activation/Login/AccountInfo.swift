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
    var requiredFields = [String]()
    var phoneNumber = ""
    var phoneMasked = ""
    var error: String?
    var errorDescription: String?

    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "user_id": "userId",
            "created_password": "createdPassword",
            "email":"email",
            "name":"name",
            "create_password_list": "requiredFields",
            "phone": "phoneNumber",
            "phone_masked" : "phoneMasked",
            "error": "error",
            "error_description": "errorDescription"
        ])
        
        return mapping
    }
}
