//
//  CartShipmentData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class CartShipmentData: NSObject {

    var form: CartShipmentForm = CartShipmentForm()

    class func mapping() -> RKObjectMapping! {
        let mapping: RKObjectMapping = RKObjectMapping(for: self)
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "form", toKeyPath: "form", with: CartShipmentForm.mapping()))

        return mapping
    }

}
