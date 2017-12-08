//
//  ReplacementDetail.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class Replacement: Unboxable {
    
    var identifier: String!
    var orderId: String!
    var paymentDate: String!
    var expiredDate: String!
    var cashback: String!
    var multiplierValue: Int!
    var multiplierText: String!
    var multiplierColor: String!
    var products: [ReplacementProduct]!
    var deadline: ReplacementDeadline!
    var destination: ReplacementDestination!
    var shipper: ReplacementShipment!
    var detail: ReplacementDetail!
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            identifier: try unboxer.unbox(key:"order_replacement_id"),
            orderId: try unboxer.unbox(key:"order_order_id"),
            paymentDate: try unboxer.unbox(key:"order_payment_at"),
            expiredDate: try unboxer.unbox(key:"order_expired_at"),
            cashback: try unboxer.unbox(key:"order_cashback"),
            multiplierValue: try unboxer.unbox(key: "replacement_multiplier_value"),
            multiplierText: try unboxer.unbox(key: "replacement_multiplier_value_str"),
            multiplierColor: try unboxer.unbox(key: "replacement_multiplier_color"),
            products: try unboxer.unbox(key:"order_products"),
            deadline: try unboxer.unbox(key:"order_deadline"),
            destination: try unboxer.unbox(key:"order_destination"),
            shipper: try unboxer.unbox(key:"order_shipment"),
            detail: try unboxer.unbox(key:"order_detail")
        )
    }
    
    init(identifier: String, orderId: String, paymentDate: String, expiredDate: String, cashback: String, multiplierValue: Int, multiplierText: String, multiplierColor: String, products: [ReplacementProduct], deadline: ReplacementDeadline, destination: ReplacementDestination, shipper: ReplacementShipment, detail: ReplacementDetail) {
        self.identifier = identifier
        self.orderId = orderId
        self.paymentDate = paymentDate
        self.expiredDate = expiredDate
        self.cashback = cashback
        self.multiplierValue = multiplierValue
        self.multiplierText = multiplierText
        self.multiplierColor = multiplierColor
        self.products = products
        self.deadline = deadline
        self.destination = destination
        self.detail = detail
        self.shipper = shipper
    }
}
