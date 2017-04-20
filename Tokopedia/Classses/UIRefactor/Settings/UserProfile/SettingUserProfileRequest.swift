//
//  SettingUserProfileRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class SettingUserProfileRequest: NSObject {
    
    class func fetchUserProfileForm(_ onSuccess:@escaping ((_ data:DataUser) -> Void), onFailure:@escaping (()->Void)){
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        let param : [String : String] = ["profile_user_id":auth.getUserId()]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(withBaseUrl: NSString.v4Url(),
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
                                                onSuccess(response.data.data_user)
                                            }
                                            
        }) { (error) in
            StickyAlertView.showErrorMessage(["error"])
            onFailure()
        }
        
    }
    
    class func fetchEditUserProfile(_ postObject:DataUser, onSuccess:@escaping (() -> Void), onFailure:@escaping (()->Void)){
        
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
        
        networkManager.request(withBaseUrl: NSString.v4Url(),
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
    
    class func fetchUploadProfilePicture(_ image:UIImage,  onSuccess:@escaping ((_ imageURLString: String) -> Void), onFailure:@escaping (()->Void)) {
                
        var generatedHost : GeneratedHost = GeneratedHost()
        var imageURLString : String = ""
        
        _ = GenerateHostObservable.getGeneratedHost()
            .flatMap { (host) -> Observable<ImageResult> in
                generatedHost = host
                return getPictObj(image, generatedHost: host)
                
            }.flatMap { (imageResult) -> Observable<String> in
                imageURLString = imageResult.file_th
                return submitProfilePicture(imageResult.pic_obj, generatedHost: generatedHost)
                
            }.subscribe(onNext: { (isSuccess) in
                    onSuccess(imageURLString)
                }, onError: { (errorType) in
                    onFailure()
            })
    }
    
    fileprivate class func getPictObj(_ image: UIImage, generatedHost:GeneratedHost) -> Observable<ImageResult>{
        
        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = generatedHost.server_id
            
            RequestUploadImage.requestUploadImage(image,
                withUploadHost: "https://\(generatedHost.upload_host)",
                path: "/web-service/v4/action/upload-image/upload_profile_image.pl",
                name: "profile_img",
                fileName: "Image",
                request: postObject,
                onSuccess: { (imageResult) in
                    if let imageResult = imageResult {
                        observer.onNext(imageResult)
                        observer.onCompleted()
                    }
                    
                }, onFailure: { (error) in
                    observer.onError(RequestError.networkError as Error)
            })
            
            return Disposables.create()
        })
    }
    
    fileprivate class func submitProfilePicture(_ fileUploaded: String, generatedHost:GeneratedHost) -> Observable<String>{
        
        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            
            let param : [String : String] = [
                "file_uploaded" : fileUploaded,
                "user_id"       : auth.getUserId()
            ]
            
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            
            networkManager.request(withBaseUrl: NSString.v4Url(),
                path: "/v4/action/people/upload_profile_picture.pl",
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
                        observer.onNext("1")
                        observer.onCompleted()
                    } else {
                        if response.message_error.count > 0{
                            StickyAlertView.showErrorMessage(response.message_error)
                        }
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            }) { (error) in
                StickyAlertView.showErrorMessage(["error"])
                observer.onError(RequestError.networkError as Error)
            }
            
            return Disposables.create()
        })
    }
    
}
