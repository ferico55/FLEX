//
//  DepositBankRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class DepositBankRequest: NSObject {

    class func fetchListAccountBank(onSuccess:(([BankAccountFormList]) -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/people/get_bank_account.pl",
                                          method: .POST,
                                          parameter: [:],
                                          mapping: V4Response.mappingWithData(BankAccountFormResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showSuccessMessage(response.message_status)
                                                onFailure()
                                            } else {
                                                onSuccess(response.data.list)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
}
