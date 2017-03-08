//
//  AddressRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class AddressRequest: NSObject {
    
    class func fetchListAddressPage(_ page:(NSInteger), query:(String), onSuccess: @escaping ((AddressFormResult) -> Void), onFailure:@escaping (()->Void)){
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let addressPage = "\(page)"
        
        let param : [String: String] = [
            "page"      : addressPage,
            "query"     : query,
            "per_page"  : "5",
        ]
        
        networkManager.request(withBaseUrl: NSString .v4Url(),
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
    
  class func fetchSetDefaultAddressID(_ addressID:String, onSuccess: @escaping ((ProfileSettingsResult) -> Void), onFailure:@escaping (()->Void)) {
    
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String: String] = [
            "address_id":addressID,
        ]
        
        networkManager.request(withBaseUrl: NSString .v4Url(),
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
    
    class func fetchDeleteAddressID(_ addressID:String, onSuccess: @escaping ((ProfileSettingsResult) -> Void), onFailure:@escaping (()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : [String: String] = [
            "address_id":addressID,
        ]
        
        networkManager.request(withBaseUrl: NSString .v4Url(),
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
