//
//  CreatePasswordUserProfile.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 6/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class CreatePasswordUserProfile: NSObject {
    var name: String?
    var email: String?
    var birthDay: String?
    var gender: String?
    var provider = ""
    var providerName = ""
    var userId = ""
    var accessToken: String?

    static func fromFacebook(userData: [String: String]) -> CreatePasswordUserProfile {
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

    static func fromGoogle(user: GIDGoogleUser) -> CreatePasswordUserProfile {
        let userProfile = CreatePasswordUserProfile()
        userProfile.email = user.profile.email
        userProfile.name = user.profile.name
        userProfile.provider = "2"
        userProfile.accessToken = user.authentication.accessToken
        userProfile.providerName = "Google"
        userProfile.userId = user.userID

        return userProfile
    }

    static func fromYahoo(token: String) -> CreatePasswordUserProfile {
        let userProfile = CreatePasswordUserProfile()
        userProfile.email = ""
        userProfile.name = ""
        userProfile.accessToken = token
        userProfile.providerName = "Yahoo"

        return userProfile
    }
}
