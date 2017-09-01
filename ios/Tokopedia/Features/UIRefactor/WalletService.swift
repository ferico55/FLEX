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

class WalletService: NSObject {
    class func getBalance(_ userId: String, onSuccess: @escaping ((WalletStore) -> Void), onFailure: @escaping ((Swift.Error) -> Void)) {
        self.getBalance(userId: userId)
            .subscribe(onNext: { wallet in
                onSuccess(wallet)
            }, onError: { error in
                onFailure(error)
            })
    }
    
    class func getBalance(userId: String) -> Observable<WalletStore> {
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        
        guard let _ = userInformation?["oAuthToken.tokenType"], let _ = userInformation?["oAuthToken.accessToken"] else {
            return Observable.create { observer in
                observer.onError(WalletError.noOAuthToken)
                return Disposables.create()
            }
        }
        
        return WalletProvider().request(.fetchStatus(userId: userId))
            .map(to: WalletStore.self)
            .do(onNext: { response in
                if #available(iOS 8.3, *) {
                    if let error = response.error, error != "invalid_request" {
                        throw error
                    }
                } else {
                    if let error = response.error {
                        throw error
                    }
                }
            })
    }
    
    class func getPendingCashBack(phoneNumber: String) -> Observable<WalletCashBackResponse> {
        if phoneNumber == "" {
            return Observable.empty()
        }
        return TokocashProvider().request(.getPendingCashBack(phoneNumber: phoneNumber)).mapJSON()
            .mapTo(object: WalletCashBackResponse.self)
            .do(onNext: { response in
                if let error = response.error, error.count > 0 {
                    throw error[0]
                }
            })
    }
    
    class func getTokoCash(userId: String, phoneNumber: String) -> Observable<WalletStore> {
        guard UserAuthentificationManager().getUserLoginData()?["oAuthToken.tokenType"] != nil else {
            return Observable.empty()
        }
        
        return self.getBalance(userId: userId)
            .flatMap { balance -> Observable<WalletStore> in
                if balance.shouldShowActivation {
                    return getPendingCashBack(phoneNumber: phoneNumber)
                        .map { cashback in
                            if cashback.data?.amount != "0",
                                let balanceData = balance.data,
                                let amount = cashback.data?.amountText {
                                let data = WalletData(action: balanceData.action,
                                                      balance: amount,
                                                      text: balanceData.text,
                                                      redirectUrl: balance.walletFullUrl(),
                                                      link: balanceData.link,
                                                      hasPendingCashback: true)
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
                    if let errors = response.dictionaryValue["message_error"]{
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
                    if let errors = response.dictionaryValue["message_error"]{
                        StickyAlertView.showErrorMessage(errors.arrayObject)
                    }
                }
                return success
        }
    }
}
