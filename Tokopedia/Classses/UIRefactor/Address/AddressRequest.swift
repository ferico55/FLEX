//
//  AddressRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class AddressRequest: NSObject {
    
    class func fetchListAddressPage(page:(NSInteger), query:(String), onSuccess: ((AddressFormResult) -> Void), onFailure:(()->Void)){
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let addressPage = "\(page)"
        
        let param : [String: String] = [
            "page"      : addressPage,
            "query"     : query,
            "per_page"  : "5",
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/people/get_address.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: AddressForm.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : AddressForm = result[""] as! AddressForm
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                if response.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }

    }
    
  class func fetchSetDefaultAddressID(addressID:String, onSuccess: ((ProfileSettingsResult) -> Void), onFailure:(()->Void)) {
    
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String: String] = [
            "address_id":addressID,
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/people/edit_default_address.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: ProfileSettings.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ProfileSettings = result[""] as! ProfileSettings
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                if response.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchDeleteAddressID(addressID:String, onSuccess: ((ProfileSettingsResult) -> Void), onFailure:(()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String: String] = [
            "address_id":addressID,
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/people/delete_address.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: ProfileSettings.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ProfileSettings = result[""] as! ProfileSettings
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                if response.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }

}
