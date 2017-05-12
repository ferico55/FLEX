//
//  UWalletStore.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class WalletStore:NSObject, Unboxable {
    let code: String?
    let message: String?
    let error: String?
    let data: WalletData?
    
    init(code:String?, message:String?, error:String?, data:WalletData?) {
        self.code = code
        self.message = message
        self.error = error
        self.data = data
    }
    
    convenience init(unboxer: Unboxer) throws {
        let code = unboxer.unbox(keyPath: "code") as String?
        let message = unboxer.unbox(keyPath: "message") as String?
        let error = unboxer.unbox(keyPath: "error") as String?
        let data = unboxer.unbox(keyPath: "data") as WalletData?
        
        self.init(code:code, message:message, error:error, data:data)
    }
    
    func isExpired() -> Bool {
        let userAuth = UserAuthentificationManager()
        let userInformation = userAuth.getUserLoginData()
        
        if let tokenType = userInformation?["oAuthToken.tokenType"] {
                return self.error == "invalid_request"
        }
        
        return true
    }
    
    
    func shouldShowActivation() -> Bool {
        return data?.link == 0
    }
    
    func walletFullUrl() -> String {
        if let data = self.data {
            if(self.shouldShowActivation()) {
                return "\(data.walletActionFullUrl())"
            } else {
                return "\(data.redirectUrl)?flag_app=1"
            }
        }
        
        return ""
    }
}
