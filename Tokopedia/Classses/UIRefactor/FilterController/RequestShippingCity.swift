//
//  RequestShippingCity.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestShippingCity: NSObject {
    
    class func fetchListShippingCity(success: (([AddressDistrict]) -> Void), failed:((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path:"/v4/address/get_shipping_city.pl",
                                          method: .GET,
                                          parameter: Dictionary(),
                                          mapping: AddressObj.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : AddressObj = result[""] as! AddressObj
                                            
                                            success(response.data.shipping_city)

                                            
        }) { (error) in
            failed(error)
        }
    }

}
