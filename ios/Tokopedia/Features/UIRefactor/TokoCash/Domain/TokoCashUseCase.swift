//
//  TokoCashUseCase.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 31/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Moya
import RxSwift

@objc public class TokoCashUseCase: NSObject {
    
    public class func requestBalance() -> Observable<WalletStore> {
        
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        let type = userInformation?["oAuthToken.tokenType"] as? String ?? ""
        let tokoCashToken = userManager.getTokoCashToken() ?? ""
        
        guard !type.isEmpty, !tokoCashToken.isEmpty else {
            return WalletProvider().request(.getToken)
                .filterSuccessfulStatusAndRedirectCodes()
                .catchError { error -> Observable<Response> in
                    if let moyaError: MoyaError = error as? MoyaError,
                        let response: Response = moyaError.response,
                        response.statusCode == 402 {
                        return Observable.error(error)
                    }
                    return Observable.empty()
                }
                .map(to: TokoCashToken.self)
                .flatMap { walletToken -> Observable<WalletStore> in
                    guard let token = walletToken.token else { return Observable.empty() }
                    SecureStorageManager().storeTokoCashToken(token)
                    return TokoCashNetworkProvider()
                        .request(.balance())
                        .filterSuccessfulStatusAndRedirectCodes()
                        .retryWithAuthIfNeeded()
                        .map(to: WalletStore.self)
                }
        }
        
        return TokoCashNetworkProvider()
            .request(.balance())
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: WalletStore.self)
        
    }
    
    public class func requestBalance(completionHandler: @escaping (WalletStore) -> Void, andErrorHandler errorHandler: @escaping (Swift.Error) -> Void) {
        TokoCashUseCase
            .requestBalance()
            .catchError { error -> Observable<WalletStore> in
                Observable.error(error)
            }
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                if let moyaError: MoyaError = error as? MoyaError,
                    let response: Response = moyaError.response {
                    let statusCode = response.statusCode
                    let errorCode = NSError(domain: "", code: statusCode, userInfo: nil)
                    errorHandler(errorCode)
                }
            })
    }
    
    public class func getWalletHistory(historyType: String, perPage: Int? = 6, page: Int? = 1, startDate: Date? = Date.aWeekAgo(), endDate: Date? = Date()) -> Observable<TokoCashHistoryResponse> {
        
        var parameter: [String: Any] = [
            "type": historyType,
            "lang": "id",
        ]
        
        if historyType != "pending" {
            let additionalParameter: [String: Any] = [
                "per_page": perPage as Any,
                "page": page as Any,
                "start_date": startDate?.tpDateFormat1() as Any,
                "end_date": endDate?.tpDateFormat1() as Any,
            ]
            parameter.merge(with: additionalParameter)
        }
        
        return TokoCashNetworkProvider()
            .request(.walletHistory(parameter: parameter))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashHistoryResponse.self)
    }
    
    public class func requestProfile() -> Observable<TokoCashProfileResponse> {
        return TokoCashNetworkProvider()
            .request(.profile())
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashProfileResponse.self)
    }
    
    public class func requestAction(URL: String, method: String, parameter: [String: String]) -> Observable<Response> {
        return TokoCashNetworkProvider()
            .request(.action(URL: URL, method: method, parameter: parameter))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
    }
    
    public class func requestRevokeAccount(revokeToken: String, identifier: String, identifierType: String) -> Observable<TokoCashResponse> {
        return TokoCashNetworkProvider()
            .request(.revokeAccount(revokeToken: revokeToken, identifier: identifier, identifierType: identifierType))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashResponse.self)
    }
    
    public class func requestQRInfo(_ identifier: String) -> Observable<TokoCashQRInfoResponse> {
        return TokoCashNetworkProvider()
            .request(.QRInfo(identifier: identifier))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashQRInfoResponse.self)
    }
    
    public class func requestPayment(_ amount: Int, notes: String, merchantIdentifier: String) -> Observable<TokoCashPaymentResponse> {
        return TokoCashNetworkProvider()
            .request(.payment(amount: amount, notes: notes, merchantIdentifier: merchantIdentifier))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashPaymentResponse.self)
    }
    
    public class func requestHelp(message: String, category: String, transactionId: String) -> Observable<TokoCashResponse> {
        return TokoCashNetworkProvider()
            .request(.help(message: message, category: category, transactionId: transactionId))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashResponse.self)
    }
}

public extension ObservableType where E == Response {
    /// Tries to refresh auth token on 401 errors and retry the request.
    /// If the refresh fails, the signal errors.
    public func retryWithAuthIfNeeded() -> Observable<E> {
        return catchError { error -> Observable<Response> in
            if let moyaError: MoyaError = error as? MoyaError {
                if let response: Response = moyaError.response {
                    if response.statusCode == 401 {
                        return self.retryAuth()
                    }
                }
            }
            return Observable.error(error)
        }
    }
    
    private func retryAuth() -> Observable<E> {
        return self.retryWhen { errorObservable -> Observable<TokoCashToken> in
            Observable.zip(errorObservable, Observable.range(start: 1, count: 3), resultSelector: { $1 }).flatMap { _ -> Observable<TokoCashToken> in
                return WalletProvider().request(.getToken)
                    .filterSuccessfulStatusAndRedirectCodes()
                    .catchError { error -> Observable<Response> in
                        if let moyaError: MoyaError = error as? MoyaError {
                            if let response: Response = moyaError.response {
                                if response.statusCode == 402 {
                                    return Observable.error(error)
                                }
                            }
                        }
                        return Observable.empty()
                    }
                    .map(to: TokoCashToken.self)
                    .do(onNext: { walletToken in
                        guard let token = walletToken.token else { return }
                        SecureStorageManager().storeTokoCashToken(token)
                    })
            }
        }
    }
}
