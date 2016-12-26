//
//  SalesOrderRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class IDropCodeRequestObject: NSObject {
    var shopID = ""
    var bookingType = ""
    var bookingToken = ""
    var bookingUT = ""
    var orderID = ""
}

class SalesOrderRequest: NSObject {
    
    class func fetchIDropCode(requestURLString: String, objectRequest: IDropCodeRequestObject, onSuccess: ((OrderBookingData) -> Void)) {
        
        let param : [String : String] = [
            "shopid"    : objectRequest.shopID,
            "type"      : objectRequest.bookingType,
            "token"     : objectRequest.bookingToken,
            "ut"        : objectRequest.bookingUT,
            "orders"    : objectRequest.orderID
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.isUsingDefaultError = false
        
        let requestURL = NSURL(string: requestURLString)
        let baseURLString = "\(requestURL!.scheme ?? "")://\(requestURL!.host ?? "")"
        let pathURLString = requestURL!.path ?? ""
        
        networkManager.requestWithBaseUrl(baseURLString,
                                          path: pathURLString,
                                          method: .GET,
                                          parameter: param,
                                          mapping: OrderBookingResponse.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! OrderBookingResponse
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                            } else {
                                                onSuccess(response.data.first!)
                                            }
        }) { (error) in
        }
    }

}
