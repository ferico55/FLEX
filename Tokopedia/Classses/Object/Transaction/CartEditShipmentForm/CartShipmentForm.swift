//
//  CartShipmentForm.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class CartShipmentForm: NSObject {
    
    var shipment : [ShippingInfoShipments] = []
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "shipment", toKeyPath: "shipment", withMapping: ShippingInfoShipments.mapping()))
        
        return mapping
    }
}
