//
//  WalletStatusRequest.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/1/16.
//  Copyright © 2016 TOKOPEDIA.     All rights reserved.
//

import UIKit

class WalletRequest: NSObject {
    
    class func fetchStatusWithUserId(_ userId: String, onSuccess: @escaping ((WalletStore) -> Void), onFailure: @escaping ((Error)->Void)){
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager.isUsingDefaultError = false
        
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
        
        let header = ["Authorization" : "\(type) \(token)"]
        
        networkManager.request(withBaseUrl: NSString.accountsUrl(),
                                          path: "/api/v1/wallet/balance",
                                          method: .GET,
                                          header: header,
                                          parameter: ["user_id" : userId],
                                          mapping: WalletStore.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : WalletStore = result[""] as! WalletStore
                                            
                                            onSuccess(response)
                                          },
                                          onFailure:  { (error) in
                                            onFailure(error)
                                          })
    }
    
}
