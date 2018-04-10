//
//  CreatePasswordUserProfile.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

public class CreatePasswordUserProfile: NSObject {
    public var name: String?
    public var email: String?
    public var birthDay: String?
    public var gender: String?
    public var provider = ""
    public var providerName = ""
    public var userId = ""
    public var accessToken: String?

    public static func fromFacebook(userData: [String: String]) -> CreatePasswordUserProfile {
        let userProfile = CreatePasswordUserProfile()
        userProfile.email = userData["email"]
        userProfile.name = userData["name"]
        userProfile.birthDay = userData["birthday"]
        userProfile.gender = userData["gender"] == "male" ? "1" : "2"
        userProfile.provider = "1"
        userProfile.accessToken = userData["accessToken"]
        userProfile.providerName = "Facebook"
        userProfile.userId = userData["id"]!

        return userProfile
    }

    public static func fromGoogle(user: GIDGoogleUser) -> CreatePasswordUserProfile {
        let userProfile = CreatePasswordUserProfile()
        userProfile.email = user.profile.email
        userProfile.name = user.profile.name
        userProfile.provider = "2"
        userProfile.accessToken = user.authentication.accessToken
        userProfile.providerName = "Google"
        userProfile.userId = user.userID

        return userProfile
    }

    public static func fromYahoo(token: String) -> CreatePasswordUserProfile {
        let userProfile = CreatePasswordUserProfile()
        userProfile.email = ""
        userProfile.name = ""
        userProfile.accessToken = token
        userProfile.providerName = "Yahoo"

        return userProfile
    }
}
