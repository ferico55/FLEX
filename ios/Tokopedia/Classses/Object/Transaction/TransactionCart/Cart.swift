//
//  Cart.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Unbox

final class Cart: Unboxable {

    var logisticFee: String = "0"
    var shipment: Shipment?

    init(logisticFee: String, shipment: Shipment?) {

        self.logisticFee = logisticFee
        self.shipment = shipment

    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            logisticFee: try unboxer.unbox(keyPath: "data.cart_logistic_fee") as String,
            shipment: try? unboxer.unbox(keyPath: "data.cart_shipments") as Shipment
        )
    }

}
