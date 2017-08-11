//
//  RequestShippingCity.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestShippingCity: NSObject {
    
    class func fetchListShippingCity(_ success: @escaping (([AddressDistrict]) -> Void), failed:@escaping ((NSError)->Void)) {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(withBaseUrl: NSString .v4Url(),
                                          path:"/v4/address/get_shipping_city.pl",
                                          method: .GET,
                                          parameter: Dictionary(),
                                          mapping: AddressObj.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : AddressObj = result[""] as! AddressObj
                                            
                                            success(response.data.shipping_city)

                                            
        }) { (error: Error!) in
            failed(error as NSError)
        }
    }

}
