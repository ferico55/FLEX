//
//  ReplacementShipment.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementShipment: Unboxable {
    
    var productId: String
    var name: String
    var product: String
    var id: String
    var logo: String
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            productId: try unboxer.unbox(key:"shipment_package_id"),
            name: try unboxer.unbox(key:"shipment_name"),
            product: try unboxer.unbox(key:"shipment_product"),
            id: try unboxer.unbox(key:"shipment_id"),
            logo: try unboxer.unbox(key:"shipment_logo")
        )
    }

    init(productId: String, name: String, product: String, id: String, logo: String) {
        self.productId = productId
        self.name = name
        self.product = product
        self.id = id
        self.logo = logo
    }
}
