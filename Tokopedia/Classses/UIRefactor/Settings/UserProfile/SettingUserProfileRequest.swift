//
//  SettingUserProfileRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class SettingUserProfileRequest: NSObject {
    
    class func fetchUserProfileForm(onSuccess: ((data:DataUser) -> Void), onFailure:(()->Void)){
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        let param : [String : String] = ["profile_user_id":auth.getUserId()]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(), path: "/v4/people/get_profile.pl", method: .GET, parameter: param, mapping: ProfileEdit.mapping() , onSuccess: { (mappingResult, operation) in
            
            let result : Dictionary = mappingResult.dictionary() as Dictionary
            let response : ProfileEdit = result[""] as! ProfileEdit
            
            if response.message_error.count > 0{
                StickyAlertView.showErrorMessage(response.message_error)
            } else {
                onSuccess(data: response.data.data_user)

            }
            
            }) { (error) in
                StickyAlertView.showErrorMessage(["error"])
        }
        
    }
    
}
