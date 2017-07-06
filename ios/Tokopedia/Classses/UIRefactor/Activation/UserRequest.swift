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
                
                let myUserID = UserAuthentificationManager().getUserId()
                if myUserID == profileInfo.result.user_info.user_id {
                    self.storeUserInformation(profileInfo)
                }
                
                onSuccess(profileInfo)
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func getUserCompletion(onSuccess:@escaping (ProfileCompletionInfo) -> Void) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        let type = userInformation?["oAuthToken.tokenType"] as! String
        let token = userInformation?["oAuthToken.accessToken"] as! String
        let headers = [
            "Authorization" : "\(type) \(token)"
        ]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/info",
            method: .GET,
            header: headers,
            parameter: [:],
            mapping: ProfileCompletionInfo.mapping(),
            onSuccess: { (mappingResult, operation) in
                let profileInfo = mappingResult.dictionary()[""] as! ProfileCompletionInfo
                onSuccess(profileInfo)
        })
    }
    
    class func editProfile(birthday:Date?, gender:String, onSuccess:@escaping(ProfileCompletionInfo) -> Void, onFailure:@escaping() -> Void) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        var dd:String = ""
        var mm:String = ""
        var yy:String = ""
        if birthday != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            let birthdayStr = dateFormatter.string(from: birthday!)
            
            let strDateArr = birthdayStr.characters.split(separator: " ")
            var month = [String : String]()
            month = ["January":"01", "February":"02", "March":"03", "April":"04", "May":"05", "June":"06", "July":"07", "August":"08", "September":"09", "October":"10", "November":"11", "December":"12"]
            dd = String(strDateArr[0])
            mm = month[String(strDateArr[1])]!
            yy = String(strDateArr[2])
        }
        
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        let type = userInformation?["oAuthToken.tokenType"] as! String
        let token = userInformation?["oAuthToken.accessToken"] as! String
        let headers = [
            "Authorization" : "\(type) \(token)"
        ]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/api/v1/user/profile-edit",
            method: .POST,
            header: headers,
            parameter: ["bday_dd" : dd,
                        "bday_mm" : mm,
                        "bday_yy" : yy,
                        "gender" : gender],
            mapping: ProfileInfo.mapping(),
            onSuccess: { (mappingResult, operation) in
                let profileInfo = mappingResult.dictionary()[""] as! ProfileCompletionInfo
                AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "DOB")
                AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "Gender")
                onSuccess(profileInfo)
        },
            onFailure: { (error) in
                AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Error", label: "DOB")
                AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Error", label: "Gender")
                onFailure()
        })
    }
    
    private class func storeUserInformation(_ profileInfo: ProfileInfo) {
        let storageManager = SecureStorageManager()
        storageManager.storeUserInformation(profileInfo.result)
        storageManager.storeShopInformation(profileInfo.result)
    }

}
