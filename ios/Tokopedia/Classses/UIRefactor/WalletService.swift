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

enum WalletError: Swift.Error {
    case noOAuthToken
}

class WalletService:NSObject {
    class func getBalance(_ userId:String, onSuccess: @escaping ((WalletStore) -> Void), onFailure: @escaping ((Swift.Error)->Void)) {
        self.getBalance(userId: userId)
            .subscribe (onNext: { wallet in
                
                let userManager = UserAuthentificationManager()
                let userInformation = userManager.getUserLoginData()
                guard let type = userInformation?["oAuthToken.tokenType"] as? String else {
                    let error = NSError(domain: "Wallet", code: 9991, userInfo: nil)
                    onFailure(error)
                    
                    return
                }
                
                guard let token = userInformation?["oAuthToken.accessToken"] as? String else {
                    let error = NSError(domain: "Wallet", code: 9992, userInfo: nil)
                    onFailure(error)
                    
                    return
                }
                
                WalletProvider().request(.fetchStatus(userId:userId)) { result in
                    if case .success(let response) = result {
                        do {
                            let wallet = try response.map(to: WalletStore.self)
                            onSuccess(wallet)
                        } catch {
                            onFailure(error)
                        }
                    } else if case .failure(let error) = result {
                        onFailure(error)
                    }
                }
            })
    }
    
    class func getBalance(userId:String) -> Observable<WalletStore> {
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        
        guard let _ = userInformation?["oAuthToken.tokenType"], let _ = userInformation?["oAuthToken.accessToken"] else {
            return Observable.create { observer in
                observer.onError(WalletError.noOAuthToken)
                return Disposables.create()
            }
        }
        
        return WalletProvider().request(.fetchStatus(userId: userId)).map(to: WalletStore.self)
    }
}
