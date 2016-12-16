//
//  LogoutRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class LogoutRequestParameter: NSObject {
    var deviceTokenID   = ""
    var deviceID        = ""
}

class LogoutRequest: NSObject {
    
    class func fetchLogout(objectRequest: LogoutRequestParameter, onSuccess: ((LogoutResult) -> Void)) {
        
        let param : [String : String] = [
            "device_id"         : objectRequest.deviceID
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.isUsingDefaultError = false

        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/session/logout.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(LogoutResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                            } else {
                                                onSuccess(response.data as! LogoutResult)
                                            }
        }) { (error) in
            
        }
    }


}
