//
//  CartEditShipmentResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class CartEditShipmentResponse: NSObject {
    
    var status:String = ""
    var message_error : [String] = []
    var message_status : [String] = []
    var data:CartShipmentData = CartShipmentData()
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromArray( [
            "status",
            "message_error",
            "message_status"
            ]
        )
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "data", withMapping: CartShipmentData.mapping()))
        
        return mapping
    }
}
