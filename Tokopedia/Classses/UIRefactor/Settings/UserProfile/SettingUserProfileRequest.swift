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
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/people/get_profile.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: ProfileEdit.mapping() ,
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ProfileEdit = result[""] as! ProfileEdit
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(data: response.data.data_user)
                                            }
                                            
        }) { (error) in
            StickyAlertView.showErrorMessage(["error"])
            onFailure()
        }
        
    }
    
    class func fetchEditUserProfile(postObject:DataUser, onSuccess: (() -> Void), onFailure:(()->Void)){
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param : [String : String] = [
            "full_name" : postObject.full_name,
            "birth_day" : postObject.birth_day,
            "birth_month" : postObject.birth_month,
            "birth_year"  : postObject.birth_year,
            "gender"      : postObject.gender,
            "hobby"     : postObject.hobby,
            "messenger" : postObject.user_messenger,
            "msisdn"    : postObject.user_phone,
            "user_password" : postObject.user_password,
            "user_id"       : auth.getUserId()
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/people/edit_biodata.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: ProfileEditForm.mapping() ,
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ProfileEditForm = result[""] as! ProfileEditForm
                                            
                                            if response.data.is_success == "1"{
                                                if response.message_status.count > 0{
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess()
                                            } else {
                                                if response.message_error.count > 0{
                                                    StickyAlertView.showErrorMessage(response.message_error)
                                                }
                                                onFailure()
                                            }
                                            
        }) { (error) in
            StickyAlertView.showErrorMessage(["error"])
            onFailure()
        }
    }
    
}
