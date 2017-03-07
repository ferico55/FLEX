//
//  CartEditShipmentResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class CartEditShipmentResponse: NSObject {
    
    var status:String = ""
    var message_error : [String] = []
    var message_status : [String] = []
    var data:CartShipmentData = CartShipmentData()
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: [
            "status",
            "message_error",
            "message_status"
            ]
        )
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", with: CartShipmentData.mapping()))
        
        return mapping
    }
}
