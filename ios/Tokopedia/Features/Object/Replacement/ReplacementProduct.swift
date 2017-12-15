//
//  ProductModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementProduct: Unboxable {
    
    var deliverQuantity: String
    var weightUnitId: String
    var orderId: String
    var status: String
    var identifier: String
    var currentWeight: String
    var thumbnailUrlString: String
    var priceWithFormat: String
    var description: String
    var price: String
    var priceCurrencyId: String
    var subtotalPriceIdr: String
    var subtotalPrice: String
    var weight: String
    var rejectQty: String
    var name: String
    var note: String?
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            deliverQuantity: try unboxer.unbox(key:"order_deliver_quantity"),
            weightUnitId: try unboxer.unbox(key:"product_weight_unit"),
            orderId: try unboxer.unbox(key:"order_detail_id"),
            status: try unboxer.unbox(key:"product_status"),
            identifier: try unboxer.unbox(key:"product_id"),
            currentWeight: try unboxer.unbox(key:"product_current_weight"),
            thumbnailUrlString: try unboxer.unbox(key:"product_picture"),
            priceWithFormat: try unboxer.unbox(key:"product_price"),
            description: try unboxer.unbox(key:"product_description"),
            price: try unboxer.unbox(key:"product_normal_price"),
            priceCurrencyId: try unboxer.unbox(key:"product_price_currency"),
            subtotalPriceIdr: try unboxer.unbox(key:"order_subtotal_price_idr"),
            subtotalPrice: try unboxer.unbox(key:"order_subtotal_price"),
            weight: try unboxer.unbox(key:"product_weight"),
            rejectQty: try unboxer.unbox(key:"product_reject_quantity"),
            name: try unboxer.unbox(key:"product_name"),
            note: try? unboxer.unbox(key:"product_notes")
        )
    }
    
    init(deliverQuantity: String, weightUnitId: String, orderId: String, status: String, identifier: String, currentWeight: String, thumbnailUrlString: String, priceWithFormat: String, description: String, price: String, priceCurrencyId: String, subtotalPriceIdr: String, subtotalPrice: String, weight: String, rejectQty: String, name: String, note: String?) {
        
        self.deliverQuantity = deliverQuantity
        self.weightUnitId = weightUnitId
        self.orderId = orderId
        self.status = status
        self.identifier = identifier
        self.currentWeight = currentWeight
        self.thumbnailUrlString = thumbnailUrlString
        self.priceWithFormat = priceWithFormat
        self.description = description
        self.price = price
        self.priceCurrencyId = priceCurrencyId
        self.subtotalPriceIdr = subtotalPriceIdr
        self.subtotalPrice = subtotalPrice
        self.weight = weight
        self.rejectQty = rejectQty
        self.name = name
        self.note = note
        
    }
    
}
