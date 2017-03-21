//
//  WalletStore.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class WalletStore: NSObject {
    var code: String = ""
    var message: String = ""
    var error: String = ""
    var data: WalletData?
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: [
            "code" : "code",
            "message" : "message",
            "error" : "error"
            ])
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: WalletData.mapping()))
        
        return mapping
    }
    
    func isExpired() -> Bool {
        let userAuth = UserAuthentificationManager()
        let userInformation = userAuth.getUserLoginData()
        
        if let tokenType = userInformation?["oAuthToken.tokenType"] {
            if tokenType != nil {
                return self.error == "invalid_request"
            }
            
            return true
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
                return "\(data.redirect_url)?flag_app=1"
            }
        }
        
        return ""
    }

}
