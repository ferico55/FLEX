//
//  UserInfo.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 6/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import RestKit
import UIKit

@objc(AccountInfo)
public class AccountInfo: NSObject {
    public var userId: String!
    public var createdPassword: Bool = false
    public var email = ""
    public var name = ""
    public var requiredFields = [String]()
    public var phoneNumber = ""
    public var phoneMasked = ""
    public var phoneVerified: Bool = false
    public var error: String?
    public var errorDescription: String?

    class public func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "user_id": "userId",
            "created_password": "createdPassword",
            "email":"email",
            "name":"name",
            "create_password_list": "requiredFields",
            "phone": "phoneNumber",
            "phone_masked" : "phoneMasked",
            "error": "error",
            "error_description": "errorDescription",
            "phone_verified": "phoneVerified"
        ])
        
        return mapping!
    }
}
