//
//  UWalletStore.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final public class WalletStore: NSObject, Unboxable {
    public let code: String?
    public let message: String?
    public let error: String?
    public let data: WalletData?
    public var shouldShowActivation: Bool {
        return self.data?.link == 0
    }
    
    public init(code: String? = "", message: String? = "", error: String? = "", data: WalletData?) {
        self.code = code
        self.message = message
        self.error = error
        self.data = data
    }
    
    convenience public init(unboxer: Unboxer) throws {
        let code = unboxer.unbox(keyPath: "code") as String?
        let message = unboxer.unbox(keyPath: "message") as String?
        let error = unboxer.unbox(keyPath: "error") as String?
        let data = unboxer.unbox(keyPath: "data") as WalletData?
        
        self.init(code: code, message: message, error: error, data: data)
    }
    
    public func isExpired() -> Bool {
        let userAuth = UserAuthentificationManager()
        let userInformation = userAuth.getUserLoginData()
        
        if userInformation?["oAuthToken.tokenType"] != nil {
            return self.error == "invalid_request"
        }
        
        return true
    }
    
    public func walletFullUrl() -> String {
        if let data = self.data {
            if self.shouldShowActivation {
                return "\(data.walletActionFullUrl())"
            } else {
                return "\(data.redirectUrl)?flag_app=1"
            }
        }
        
        return ""
    }
}
