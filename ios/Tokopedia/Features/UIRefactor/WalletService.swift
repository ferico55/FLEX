//
//  WalletService.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Unbox
import UIKit
import MoyaUnbox
import SwiftyJSON

enum WalletError: Swift.Error {
    case noOAuthToken
}

enum OTPAcceptType: String {
    case sms = "sms"
    case call = "call"
}

class WalletService: NSObject {
    
    class func getPendingCashBack(phoneNumber: String) -> Observable<WalletCashBackResponse> {
        if phoneNumber == "" {
            return Observable.empty()
        }
        return TokocashNetworkProvider().request(.getPendingCashBack(phoneNumber: phoneNumber)).mapJSON()
            .mapTo(object: WalletCashBackResponse.self)
            .do(onNext: { response in
                if let error = response.error, error.count > 0 {
                    throw error[0]
                }
            })
    }
    
    class func getPendingCashback(phoneNumber: String, completionHandler: @escaping (WalletCashBackResponse?) -> Void, andErrorHandler errorHandler: @escaping (Swift.Error) -> Void) {
        let _ = WalletService.getPendingCashBack(phoneNumber: phoneNumber)
            .map { cashbackResponse -> WalletCashBackResponse? in
                return cashbackResponse
            }
            .catchError({ (error) -> Observable<WalletCashBackResponse?> in
                return Observable.just(nil)
            })
            .subscribe( onNext: { response in
                completionHandler(response)
            }, onError: { [] error in
                errorHandler(error)
            })
    }
    
    class func getTokoCash(userId: String, phoneNumber: String) -> Observable<WalletStore> {
        guard UserAuthentificationManager().getUserLoginData()?["oAuthToken.tokenType"] != nil else {
            return Observable.empty()
        }
        
        return TokoCashUseCase.requestBalance()
            .flatMap { balance -> Observable<WalletStore> in
                if balance.shouldShowActivation {
                    return getPendingCashBack(phoneNumber: phoneNumber)
                        .map { cashback in
                            if cashback.data?.amount != "0",
                                let balanceData = balance.data,
                                let amount = cashback.data?.amountText {
                                let data = WalletData(action: balanceData.action,
                                                      balance: amount,
                                                      rawBalance: 0,
                                                      totalBalance: "",
                                                      rawTotalBalance: 0,
                                                      holdBalance: "",
                                                      rawHoldBalance: 0,
                                                      rawThreshold: 0,
                                                      text: balanceData.text,
                                                      redirectUrl: balance.walletFullUrl(),
                                                      link: balanceData.link,
                                                      hasPendingCashback: true,
                                                      applinks: balanceData.applinks)
                                let wallet = WalletStore(code: balance.code, message: balance.message, error: balance.error, data: data)
                                return wallet
                            }
                            return balance
                        }
                }
                return Observable.just(balance)
            }
    }
    
    class func activationTokoCash(verificationCode: String) -> Observable<Bool> {
        return WalletProvider().request(.activationTokoCash(verificationCode: verificationCode))
            .mapJSON()
            .map { response -> Bool in
                let response = JSON(response)
                let success = response.dictionaryValue["data"]?.dictionaryValue["success"]?.boolValue ?? false
                if !success {
                    if let errors = response.dictionaryValue["message_error"] {
                        StickyAlertView.showErrorMessage(errors.arrayObject)
                    }
                }
                return success
            }
    }
    
    class func requestOTPTokoCash() -> Observable<Bool> {
        return WalletProvider().request(.OTPTokoCash)
            .mapJSON()
            .map { response -> Bool in
                let response = JSON(response)
                let success = response.dictionaryValue["data"]?.dictionaryValue["success"]?.boolValue ?? false
                if !success {
                    if let errors = response.dictionaryValue["message_error"] {
                        StickyAlertView.showErrorMessage(errors.arrayObject)
                    }
                }
                return success
            }
    }
    
    class func checkPhoneNumberTokoCash(phoneNumber: String) -> Observable<TokoCashLoginSendOTPResponse> {
        return TokocashNetworkProvider().request(.checkPhoneNumber(phoneNumber: phoneNumber))
            .mapJSON()
            .flatMap({ (response) -> Observable<TokoCashLoginSendOTPResponse> in
                let response = JSON(response)
                let responseCode = response["code"].stringValue
                let isAccountExist = response["data"]["tokopedia_account_exist"].boolValue
                let isTokoCashExist = response["data"]["tokocash_account_exist"].boolValue
                // MARK: Response code from check msisdn is 2000000 or Success
                if responseCode == "200000" && isAccountExist || isTokoCashExist {
                    return self.requestOTPLoginTokoCash(phoneNumber: phoneNumber, accept: .sms)
                }
                return Observable.of(TokoCashLoginSendOTPResponse(code: "", otpAttempLeft: 0, sent: false, phoneNumber: phoneNumber))
            })
    }
    
    class func requestOTPLoginTokoCash(phoneNumber: String, accept: OTPAcceptType) -> Observable<TokoCashLoginSendOTPResponse> {
        return TokocashNetworkProvider().request(.sendOTP(phoneNumber: phoneNumber, accept: accept))
            .mapJSON()
            .map { response -> TokoCashLoginSendOTPResponse in
                let response = JSON(response)
                return TokoCashLoginSendOTPResponse(json: response, phoneNumber: phoneNumber)
            }
    }
    
    class func verifyOTPLoginTokoCash(phoneNumber: String, otpCode: String) -> Observable<TokoCashLoginVerifyOTPResponse> {
        return TokocashNetworkProvider().request(.verifyOTP(phoneNumber: phoneNumber, otpCode: otpCode))
            .mapJSON()
            .map { response -> TokoCashLoginVerifyOTPResponse in
                let response = JSON(response)
                return TokoCashLoginVerifyOTPResponse(json: response)
            }
    }
    
    class func getCodeToHandshakeWithAccount(key: String, email: String) -> Observable<TokoCashGetCodeResponse> {
        return TokocashNetworkProvider().request(.getCodeFromTokocash(key: key, email: email))
            .mapJSON()
            .map { response -> TokoCashGetCodeResponse in
                let response = JSON(response)
                return TokoCashGetCodeResponse(json: response)
            }
    }
}
