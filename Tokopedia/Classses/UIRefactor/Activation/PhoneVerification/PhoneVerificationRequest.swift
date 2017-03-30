//
//  PhoneVerificationRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class PhoneVerificationRequest: NSObject {
    class func checkPhoneVerifiedStatus(onSuccess: @escaping ((String) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/msisdn/get_verification_number_form.pl",
            method: .GET,
            parameter: [:],
            mapping: VerifiedStatus.mapping(),
            onSuccess: { (mappingResult, operation) in
                let result = mappingResult.dictionary()[""] as! VerifiedStatus
                let isVerified = result.result.msisdn.is_verified
                
                onSuccess(isVerified!)
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func getPhoneNumber(onSuccess: @escaping ((String) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let userID = userManager.getUserId()
        
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/people/get_profile.pl",
            method: .GET,
            parameter: ["profile_user_id" : userID!],
            mapping: ProfileEdit.mapping(),
            onSuccess: { (mappingResult, operation) in
                let result = mappingResult.dictionary()[""] as! ProfileEdit
                let phoneNumber = result.data.data_user.user_phone
                
                if result.message_error != nil && result.message_error.count > 0 {
                    StickyAlertView.showErrorMessage(result.message_error)
                } else {
                    onSuccess(phoneNumber!)
                }
        },
            onFailure: { (error) in
                onFailure()
        })
        
    }
    
    class func requestOTP(withMode otpMode: String, otpType: String, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let userID = userManager.getUserId()
        let tokenType = userManager.getUserLoginData()?["oAuthToken.tokenType"] as? String
        let accessToken = userManager.getUserLoginData()?["oAuthToken.accessToken"] as? String
        
        let requestHeader = ["Authorization" : "\(tokenType!) \(accessToken!)"]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/otp/request",
            method: .POST,
            header: requestHeader,
            parameter: ["mode" : otpMode,
                        "otp_type" : otpType],
            mapping: V4Response<SecurityRequestOTP>.mapping(withData: SecurityRequestOTP.mapping()),
            onSuccess: { (mappingResult, operation) in
                let otp = mappingResult.dictionary()[""] as! V4Response<SecurityRequestOTP>
                
                if otp.message_error != nil && otp.message_error.count > 0 {
                    StickyAlertView.showErrorMessage(otp.message_error)
                    onFailure()
                }
                
                if otp.message_status != nil && otp.message_status.count > 0 {
                    StickyAlertView.showSuccessMessage(otp.message_status)
                    onSuccess()
                }
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func requestOTP(withMode otpMode: String, phoneNumber number: String, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let userID = userManager.getUserId()
        let tokenType = userManager.getUserLoginData()?["oAuthToken.tokenType"] as? String
        let accessToken = userManager.getUserLoginData()?["oAuthToken.accessToken"] as? String
        
        let requestHeader = ["Authorization" : "\(tokenType!) \(accessToken!)"]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/otp/request",
            method: .POST,
            header: requestHeader,
            parameter: ["mode" : otpMode,
                        "otp_type" : "11",
                        "msisdn" : number],
            mapping: V4Response<SecurityRequestOTP>.mapping(withData: SecurityRequestOTP.mapping()),
            onSuccess: { (mappingResult, operation) in
                let otp = mappingResult.dictionary()[""] as! V4Response<SecurityRequestOTP>
                
                if otp.message_error != nil && otp.message_error.count > 0 {
                    StickyAlertView.showErrorMessage(otp.message_error)
                    onFailure()
                }
                
                if otp.message_status != nil && otp.message_status.count > 0 {
                    StickyAlertView.showSuccessMessage(otp.message_status)
                    onSuccess()
                }
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func requestVerify(withOTPCode code: String, phoneNumber number: String, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        _ = self.requestVerifyOTP(code)
            .flatMap({ (isSuccess) -> Observable<String> in
                return self.requestVerifyPhoneNumber(number)
            })
            .subscribe(
                onNext: { (success) in
                    onSuccess()
            },
                onError: { (error) in
                    onFailure()
            }
        )
        
    }
    
    class func requestVerifyOTP(_ code: String) -> Observable<String> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let userID = userManager.getUserId()
        
        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/otp/validate",
                method: .POST,
                parameter: ["user" : userID!,
                            "code" : code],
                mapping: V4Response<AnyObject>.mapping(withData: GeneralActionResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    let result: Dictionary = mappingResult.dictionary() as Dictionary
                    let response: V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                    let data = response.data as! GeneralActionResult
                    
                    guard response.message_error.count == 0 else {
                        StickyAlertView.showErrorMessage(response.message_error)
                        observer.onError(RequestError.networkError as Error)
                        return;
                    }
                    
                    if data.is_success == "1" {
                        observer.onNext(data.is_success)
                    } else {
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            },
                onFailure: { (error) in
                    observer.onError(RequestError.networkError as Error)
            })
            
            return Disposables.create()
        })
    }
    
    class func requestVerifyPhoneNumber(_ number: String) -> Observable<String> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        let tokenType = userManager.getUserLoginData()?["oAuthToken.tokenType"] as? String
        let accessToken = userManager.getUserLoginData()?["oAuthToken.accessToken"] as? String
        
        let requestHeader = ["Authorization" : "\(tokenType!) \(accessToken!)"]
        
        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/api/msisdn/verify-msisdn",
                method: .POST,
                header: requestHeader,
                parameter: ["phone" : number],
                mapping: V4Response<AnyObject>.mapping(withData: GeneralActionResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                    
                    if response.message_error.count > 0{
                        StickyAlertView.showErrorMessage(response.message_error)
                    }
                    
                    if (response.data.is_success == "1") {
                        if response.message_status.count > 0 {
                            StickyAlertView.showSuccessMessage(response.message_status)
                        }
                        observer.onNext("1")
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError as Error)
                    }
            },
                
                onFailure: { (error) in
                    observer.onError(RequestError.networkError as Error)
            })
            
            return Disposables.create()
        })
        
    }
    
}
