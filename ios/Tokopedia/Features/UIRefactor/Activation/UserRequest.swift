//
//  UserRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox
import RxSwift

class UserRequest: NSObject {

    class func getUserInformation(withUserID userID: String, onSuccess: @escaping ((ProfileInfo) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/people/get_people_info.pl",
            method: .GET,
            parameter: ["profile_user_id": userID],
            mapping: ProfileInfo.mapping(),
            onSuccess: { mappingResult, _ in
                let profileInfo = mappingResult.dictionary()[""] as! ProfileInfo

                let myUserID = UserAuthentificationManager().getUserId()
                if myUserID == profileInfo.result.user_info.user_id {
                    self.storeUserInformation(profileInfo)
                }

                onSuccess(profileInfo)
            },
            onFailure: { _ in
                onFailure()
        })
    }

    class func getUserCompletion(onSuccess: @escaping (ProfileCompletionInfo) -> Void, onFailure: @escaping () -> Void) {
        let provider = AccountProvider()
        _ = provider.request(.getInfo)
            .map(to: ProfileCompletionInfo.self)
            .subscribe({ event in
                switch event {
                case let .next(info):
                    onSuccess(info)
                case .error :
                    onFailure()
                default:
                    break
                }
            })
    }

    class func editProfile(birthday: Date?, gender: Int, onSuccess: @escaping (APIAction) -> Void, onFailure: @escaping () -> Void) {
        let provider = AccountProvider()
        _ = provider.request(.editProfile(withBirthday: birthday, gender: gender))
            .map(to: APIAction.self)
            .subscribe({ event in
                switch event {
                case let .next(info):
                    onSuccess(info)
                    AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "DOB")
                    AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "Gender")
                case .error:
                    onFailure()
                default:
                    break
                }
            })
    }

    private class func storeUserInformation(_ profileInfo: ProfileInfo) {
        let storageManager = SecureStorageManager()
        storageManager.storeUserInformation(profileInfo.result)
        storageManager.storeShopInformation(profileInfo.result)
    }
}
