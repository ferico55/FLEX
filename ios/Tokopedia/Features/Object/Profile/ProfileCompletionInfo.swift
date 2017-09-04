//
//  ProfileCompletionInfo.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 6/9/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(ProfileCompletionInfo)
final class ProfileCompletionInfo: NSObject {
    var gender: Int
    var phoneVerified: Bool
    var bday: String
    var completion: Int

    init(gender: Int = 3, phoneVerified: Bool = false, bday: String = "0001-01-01T00:00:00Z", completion: Int = 0) throws {
        self.gender = gender
        self.phoneVerified = phoneVerified
        self.bday = bday
        self.completion = completion
    }
}

extension ProfileCompletionInfo: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let gender: Int?
        do {
            gender = try unboxer.unbox(keyPath: "gender") as Int
        } catch {
            gender = 0
        }
        let phoneVerified = try unboxer.unbox(keyPath: "phone_verified") as Bool
        let bday = try unboxer.unbox(keyPath: "bday") as String
        let completion = try unboxer.unbox(keyPath: "completion") as Int

        try self.init(gender: gender!, phoneVerified: phoneVerified, bday: bday, completion: completion)
    }
}
