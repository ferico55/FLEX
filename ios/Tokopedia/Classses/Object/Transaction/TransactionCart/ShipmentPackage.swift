//
//  ShipmentPackage.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Unbox

final class ShipmentPackage: Unboxable {
    
    var id = ""
    var name = ""
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init(unboxer: Unboxer) throws {
        self.init(
            id: try unboxer.unbox(keyPath: "shipment_package_id"),
            name: try unboxer.unbox(keyPath: "shipment_package_name")
        )
    }

}
