//
//  ProfileCompletionInfo.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(ProfileCompletionInfo)
public final class ProfileCompletionInfo: NSObject {
    public var gender: Int
    public var phoneVerified: Bool
    public var bday: String
    public var completion: Int
    public var hasEmail: Bool
    public var createdPassword: Bool

    public init(gender: Int = 3,
                phoneVerified: Bool = false,
                bday: String = "0001-01-01T00:00:00Z",
                completion: Int = 0,
                hasEmail: Bool = false,
                createdPassword: Bool = false) throws {
        self.gender = gender
        self.phoneVerified = phoneVerified
        self.bday = bday
        self.completion = completion
        self.hasEmail = hasEmail
        self.createdPassword = createdPassword
    }
}

extension ProfileCompletionInfo: Unboxable {
    public convenience init(unboxer: Unboxer) throws {
        let gender = (try? unboxer.unbox(keyPath: "gender") as Int) ?? 0
        let phoneVerified = try unboxer.unbox(keyPath: "phone_verified") as Bool
        let bday = try unboxer.unbox(keyPath: "bday") as String
        let completion = try unboxer.unbox(keyPath: "completion") as Int
        let hasEmail = (try? unboxer.unbox(keyPath: "email_phonenumber") as Bool) ?? false
        let createdPassword = (try? unboxer.unbox(keyPath: "created_password") as Bool) ?? false

        try self.init(gender: gender,
                      phoneVerified: phoneVerified,
                      bday: bday,
                      completion: completion,
                      hasEmail: hasEmail,
                      createdPassword: createdPassword)
    }
}
