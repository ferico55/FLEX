//
//  TokoCashUseCase.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 31/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import Moya

@objc class TokoCashUseCase: NSObject {
    
    class func requestBalance() -> Observable<WalletStore> {
        return TokocashNetworkProvider()
            .request(.balance())
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: WalletStore.self)
    }
    
    class func requestBalance(completionHandler: @escaping (WalletStore) -> Void, andErrorHandler errorHandler: @escaping (Swift.Error) -> Void) {
        TokoCashUseCase
            .requestBalance()
            .catchError { error -> Observable<WalletStore> in
                return Observable.error(error)
            }
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                errorHandler(error)
            })
    }
    
    class func getWalletHistory(historyType: String, perPage: Int? = 6, page: Int? = 1, startDate: Date? = Date.aWeekAgo(), endDate: Date? = Date(), afterId: String? = "") -> Observable<TokoCashHistoryResponse> {
        
        var parameter: [String: Any] = [
            "type": historyType,
            "lang": "id"
        ]
        
        if historyType != "pending" {
            let additionalParameter: [String: Any] = [
                "per_page": perPage,
                "page": page,
                "start_date": startDate?.tpDateFormat1(),
                "end_date": endDate?.tpDateFormat1(),
                "after_id": afterId
            ]
            
            parameter.merge(with: additionalParameter)
        }
        
        return TokocashNetworkProvider()
            .request(.walletHistory(parameter: parameter))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashHistoryResponse.self)
    }
    
    class func requestProfile() -> Observable<TokoCashProfileResponse> {
        return TokocashNetworkProvider()
            .request(.profile())
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashProfileResponse.self)
    }
    
    class func requestAction(URL: String, method: String, parameter: [String: String]) -> Observable<Response> {
        return TokocashNetworkProvider()
            .request(.action(URL: URL, method: method, parameter: parameter))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
    }
    
    class func requestRevokeAccount(revokeToken: String, identifier: String, identifierType: String) -> Observable<TokoCashResponse> {
        return TokocashNetworkProvider()
            .request(.revokeAccount(revokeToken: revokeToken, identifier: identifier, identifierType: identifierType))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashResponse.self)
    }
    
    class func requestQRInfo(_ identifier: String) -> Observable<TokoCashQRInfoResponse> {
        return TokocashNetworkProvider()
            .request(.QRInfo(identifier: identifier))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashQRInfoResponse.self)
    }
    
    class func requestPayment(_ amount: Int, notes: String, merchantIdentifier: String) -> Observable<TokoCashPaymentResponse> {
        return TokocashNetworkProvider()
            .request(.payment(amount: amount, notes: notes, merchantIdentifier: merchantIdentifier))
            .filterSuccessfulStatusAndRedirectCodes()
            .retryWithAuthIfNeeded()
            .map(to: TokoCashPaymentResponse.self)
    }
    
    class func requestHelp(message: String, category: String, transactionId: String) -> Observable<TokoCashResponse> {
        return TokocashNetworkProvider()
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
