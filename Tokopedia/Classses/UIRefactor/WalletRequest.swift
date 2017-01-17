//
//  WalletStatusRequest.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/1/16.
//  Copyright © 2016 TOKOPEDIA.     All rights reserved.
//

import UIKit

class WalletRequest: NSObject {
    
    class func fetchStatusWithUserId(userId: String, onSuccess: ((WalletStore) -> Void), onFailure:((NSError)->Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager.isUsingDefaultError = false
        
        let userManager = UserAuthentificationManager()
        let userInformation = userManager.getUserLoginData()
        
        guard let type = userInformation["oAuthToken.tokenType"] else { return }
        guard let token = userInformation["oAuthToken.accessToken"] else { return }
        
        let header = ["Authorization" : "\(type) \(token)"]
        
        networkManager.requestWithBaseUrl(NSString.accountsUrl(),
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
