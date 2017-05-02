//
//  ShipmentRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum ProceedType: NSInteger {
    case confirm, reject, accept, partial
    func stringDescription() -> String {
        switch self {
        case .confirm:
            return "confirm"
        case .reject:
            return "reject"
        case .accept:
            return "accept"
        case .partial:
            return "partial"
        }
    }
}

class ProceedShippingObjectRequest: NSObject {
    var type : ProceedType = .confirm
    var orderID : String = ""
    var reason : String = ""
    var day : String = ""
    var month : String = ""
    var year : String = ""
    var shipmentID : String = ""
    var shipmentName : String = ""
    var shippingRef : String = ""
    var shipmentPackageID : String = ""
}

class ShipmentRequest: NSObject {
    
    class func fetchProceedShipping(_ requestObject:ProceedShippingObjectRequest, onSuccess: @escaping (() -> Void), onFailure: @escaping (()->Void)) {
        
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let auth = UserAuthentificationManager()
        
        let param : [String : String] = [
            "action_type"   : requestObject.type.stringDescription(),
            "order_id"      : requestObject.orderID,
            "reason"        : requestObject.reason,
            "ship_day"      : requestObject.day,
            "ship_month"    : requestObject.month,
            "ship_year"     : requestObject.year,
            "shipment_id"   : requestObject.shipmentID,
            "shipment_name" : requestObject.shipmentName,
            "shipping_ref"  : requestObject.shippingRef,
            "sp_id"         : requestObject.shipmentPackageID,
            "user_id"       : auth.getUserId()
        ]
        
        networkManager.request(withBaseUrl: NSString .v4Url(),
                                          path: "/v4/action/myshop-order/proceed_shipping.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: GeneralAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : [AnyHashable : Any] = mappingResult.dictionary() as [AnyHashable : Any]
                                            let response : GeneralAction = result[""] as! GeneralAction
                                            
                                            if response.data.is_success == "1"{
                                                if (response.message_status?.count)!>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess()
                                            } else {
                                                if let errors = response.message_error{
                                                    StickyAlertView.showErrorMessage(errors)
                                                } else {
                                                    StickyAlertView.showErrorMessage(["Gagal Memproses"])
                                                }
                                                onFailure()
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }

}
