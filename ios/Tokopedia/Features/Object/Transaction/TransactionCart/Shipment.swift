//
//  Shipment.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Unbox

final class Shipment: Unboxable {

    var pickup = ""
    var image = ""
    var id = ""
    var name = ""
    var note = ""
    var package: ShipmentPackage?

    init(pickup: String, image: String, id: String, note: String, name: String, package: ShipmentPackage?) {
        self.pickup = pickup
        self.image = image
        self.id = id
        self.note = note
        self.name = name
        self.package = package
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            pickup: try unboxer.unbox(keyPath: "shipment_pickup"),
            image: try unboxer.unbox(keyPath: "shipment_image"),
            id: try unboxer.unbox(keyPath: "shipment_id"),
            note: try unboxer.unbox(keyPath: "shipment_notes"),
            name: try unboxer.unbox(keyPath: "shipment_name"),
            package: try? unboxer.unbox(keyPath: "") as ShipmentPackage
        )

    }
}
