//
//  UserRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class UserRequest: NSObject {
    
    class func getUserInformation(withUserID userID: String, onSuccess:@escaping((ProfileInfo) -> Void), onFailure:@escaping(() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/people/get_people_info.pl",
            method: .GET,
            parameter: ["profile_user_id" : userID],
            mapping: ProfileInfo.mapping(),
            onSuccess: { (mappingResult, operation) in
                let profileInfo = mappingResult.dictionary()[""] as! ProfileInfo
                self.storeUserInformation(profileInfo)
                onSuccess(profileInfo)
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    private class func storeUserInformation(_ profileInfo: ProfileInfo) {
        let storageManager = SecureStorageManager()
        storageManager.storeUserInformation(profileInfo.result)
    }

}
