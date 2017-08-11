//
//  CartShipmentForm.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class CartShipmentForm: NSObject {

    var shipment: [ShippingInfoShipments] = []

    class func mapping() -> RKObjectMapping! {
        let mapping: RKObjectMapping = RKObjectMapping(for: self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "shipment", toKeyPath: "shipment", with: ShippingInfoShipments.mapping()))

        return mapping
    }
}
