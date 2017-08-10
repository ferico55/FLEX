//
//  OTPRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController

@objc enum OTPType: Int {
    case phoneVerification = 11
    case bankAccount = 12
    case securityQuestion = 13
}

class OTPRequest: NSObject {
    
    var token: String = ""
    
    //MARK: Get OTP Request
    class func requestOTP(withMode otpMode: String, type: OTPType, userID: String?, number: String, token: OAuthToken?, onSuccess: @escaping ((SecurityRequestOTP) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let userManager = UserAuthentificationManager()
        
        var tokenType = ""
        var accessToken = ""
        
        if token != nil {
            tokenType = (token?.tokenType)!
            accessToken = (token?.accessToken)!
        } else {
            tokenType = (userManager.getUserLoginData()?["oAuthToken.tokenType"] as? String)!
            accessToken = (userManager.getUserLoginData()?["oAuthToken.accessToken"] as? String)!
        }
        
        let requestHeader = ["Tkpd-UserId" : userID ?? userManager.getUserId()!,
                             "Authorization" : "\(tokenType) \(accessToken)"]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/otp/request",
            method: .POST,
            header: requestHeader,
            parameter: ["mode" : otpMode,
                        "otp_type" : String(type.rawValue),
                        "msisdn" : number],
            mapping: SecurityRequestOTP.mapping(),
            onSuccess: { (mappingResult, operation) in
                let otp = mappingResult.dictionary()[""] as! SecurityRequestOTP
                
                if otp.message_error != nil && otp.message_error.count > 0 {
                    StickyAlertView.showErrorMessage(otp.message_error)
                    onFailure()
                }
                
                if otp.message_status != nil && otp.message_status.count > 0 {
                    StickyAlertView.showSuccessMessage(otp.message_status)
                    onSuccess(otp)
                }
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    //MARK: Phone Verification Request Methods
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
                
                onSuccess(isVerified)
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
    
    
    //MARK: Verify OTP & Phone Number
    class func requestVerify(withOTPCode code: String, phoneNumber number: String, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
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
    
    //MARK: Security Question Request Methods
    class func requestQuestionForm(withUserCheckSecurityOne questionType1: String, userCheckSecurityTwo questionType2: String, userID user: String, deviceID device: String, onSuccess: @escaping ((SecurityQuestion) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let parameter = ["user_check_security_1" : questionType1,
                         "user_check_security_2" : questionType2,
                         "user_id" : user,
                         "device_id" : device]
        
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/interrupt/get_question_form.pl",
            method: .GET,
            parameter: parameter,
            mapping: SecurityQuestion.mapping(),
            onSuccess: { (mappingResult, operation) in
                let result = mappingResult.dictionary()[""] as! SecurityQuestion
                onSuccess(result)
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func requestVerifySecurityQuestion(withQuestion question: String, inputAnswer answer: String, userCheckSecurityOne questionType1: String, userCheckSecurityTwo questionType2: String, userID user: String, onSuccess: @escaping ((SecurityAnswer) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let parameter = ["question" : question,
                         "answer" : answer,
                         "user_check_security_1" : questionType1,
                         "user_check_security_2" : questionType2,
                         "user_id" : user]
        
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/action/interrupt/answer_question.pl",
            method: .POST,
            parameter: parameter,
            mapping: SecurityAnswer.mapping(),
            onSuccess: { (mappingResult, operation) in
                let result = mappingResult.dictionary()[""] as! SecurityAnswer
                onSuccess(result)
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    //MARK: Change Phone Number on Security Question
    class func checkChangePhoneNumberStatus(withToken token: OAuthToken,
                                            onSuccess: @escaping ((Bool) -> Void),
                                            onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let header = ["Authorization" : "\(token.tokenType!) \(token.accessToken!)"]
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/api/ktp/check-status",
            method: .POST,
            header: header,
            parameter: [:],
            mapping: V4Response<ChangePhoneNumberStatus>.mapping(withData: ChangePhoneNumberStatus.mapping()),
            onSuccess: { (mappingResult, operation) in
                let status = mappingResult.dictionary()[""] as! V4Response<ChangePhoneNumberStatus>
                
                if status.message_error != nil && status.message_error.count > 0 {
                    StickyAlertView.showErrorMessage(status.message_error)
                } else {
                    if status.message_status != nil && status.message_status.count > 0 {
                        StickyAlertView.showSuccessMessage(status.message_status)
                    }
                    
                    onSuccess(status.data.isPending)
                }
        },
            onFailure: { (error) in
                onFailure()
        })
    }
    
    class func submitKTPAndTabungan(withKTPImage ktp: AttachedImageObject,
                                    tabungan: AttachedImageObject,
                                    userID: String,
                                    oAuthToken: OAuthToken,
                                    onSuccess: @escaping ((String) -> Void),
                                    onFailure: @escaping (() -> Void)) {
        var ktpWidth = ""
        var ktpHeight = ""
        var tabunganWidth = ""
        var tabunganHeight = ""
        
        //Get image sizes
        ktp.asset.fetchOriginalImage(false, completeBlock: { (ktpImage, info) in
            ktpWidth = String(Int((ktpImage?.size.width)!))
            ktpHeight = String(Int((ktpImage?.size.height)!))
            
            tabungan.asset.fetchOriginalImage(false, completeBlock: { (tabunganImage, info) in
                tabunganWidth = String(Int((tabunganImage?.size.height)!))
                tabunganHeight = String(Int((tabunganImage?.size.height)!))
                
                var requestToken: String?
                var host: GeneratedHost?
                
                _ = self.validateImageSize(
                    withUserID: userID,
                    oAuthToken: oAuthToken,
                    ktpWidth: ktpWidth,
                    ktpHeight: ktpHeight,
                    tabunganWidth: tabunganWidth,
                    tabunganHeight: tabunganHeight)
                    .flatMap({ (token) -> Observable<GeneratedHost> in
                        requestToken = token
                        return GenerateHostObservable.getAccountsGeneratedHost(userID, token: oAuthToken)
                    })
                    .flatMap({ (generatedHost) -> Observable<ImageResult> in
                        host = generatedHost
                        return UploadImageObserver.requestUploadAccountsImage(host!, token: requestToken!, imageObject: ktp, userID: userID)
                    })
                    .flatMap({ (ktpResult) -> Observable<ImageResult> in
                        return UploadImageObserver.requestUploadAccountsImage(host!, token: requestToken!, imageObject: tabungan, userID: userID)
                    })
                    .flatMap({ (tabunganResult) -> Observable<String> in
                        return self.getFileUploaded(withKTPImage: ktp, tabungan: tabungan)
                    })
                    .flatMap({ (fileUploaded) -> Observable<String> in
                        return self.requestSubmit(fileUploaded, userID: userID, token: oAuthToken)
                    })
                    .subscribe(
                        onNext: { (success) in
                            onSuccess(success)
                    },
                        onError: { (error) in
                            onFailure()
                    })
            })
        })
    }
    
    class func validateImageSize(withUserID userID: String, oAuthToken: OAuthToken, ktpWidth: String, ktpHeight: String, tabunganWidth: String, tabunganHeight: String) -> Observable<String> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let tokenType = oAuthToken.tokenType
        let accessToken = oAuthToken.accessToken
        
        let requestHeader = ["Authorization" : "\(tokenType!) \(accessToken!)"]
        
        let parameter = ["user_id" : userID,
                         "ktp_width" : ktpWidth,
                         "ktp_height" : ktpHeight,
                         "bankbook_width" : tabunganWidth,
                         "bankbook_height" : tabunganHeight]
        
        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/api/image/validate-size",
                method: .POST,
                header: requestHeader,
                parameter: parameter,
                mapping: V4Response<ImageSizeValidation>.mapping(withData: ImageSizeValidation.mapping()),
                onSuccess: { (mappingResult, operation) in
                    let imageSizeValidation = mappingResult.dictionary()[""] as! V4Response<ImageSizeValidation>
                    
                    if imageSizeValidation.data.isSuccess {
                        observer.onNext(imageSizeValidation.data.token)
                    } else {
                        if imageSizeValidation.message_error != nil && imageSizeValidation.message_error.count > 0 {
                            StickyAlertView.showErrorMessage(imageSizeValidation.message_error)
                        }
                        observer.onError(RequestError.networkError as Error)
                    }
            },
                onFailure: { (error) in
                    observer.onError(RequestError.networkError as Error)
            })
            
            return Disposables.create()
        })
    }
    
    class func getFileUploaded(withKTPImage ktp: AttachedImageObject, tabungan: AttachedImageObject) -> Observable<String> {
        let imagesDictionary: NSMutableDictionary = NSMutableDictionary()
        
        imagesDictionary["ktp"] = ktp.picObj
        imagesDictionary["tabungan"] = tabungan.picObj
        
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(imagesDictionary.json)
            
            return Disposables.create()
        })
    }
    
    class func requestSubmit(_ fileUploaded: String, userID: String, token: OAuthToken) -> Observable<String> {
        return Observable.create({ (observer) -> Disposable in
            let networkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            
            let header = ["Authorization" : "\(token.tokenType!) \(token.accessToken!)"]
            
            let parameter = ["user_id" : userID,
                             "file_uploaded" : fileUploaded]
            
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/api/image/submit-detail",
                method: .POST,
                header: header,
                parameter: parameter,
                mapping: V4Response<GeneralActionResult>.mapping(withData: GeneralActionResult.mapping()), onSuccess: { (mappingResult, operation) in
                    let result : V4Response<GeneralActionResult> = mappingResult.dictionary()[""] as! V4Response<GeneralActionResult>
                    
                    if result.data.is_success == "1" {
                        observer.onNext(result.data.is_success)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError as Error)
                    }
            }, onFailure: { (error) in
                observer.onError(RequestError.networkError as Error)
            })
            
            return Disposables.create()
        })
    }
}
