//
//  RCOrder.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCOrder: NSObject {
    var detail: RCOrderDetail = RCOrderDetail()
    var product: RCProduct = RCProduct()
    var shipping: RCShipping = RCShipping()
    override init(){}
    init(json:[String:JSON]) {
        if let detail = json["detail"]?.dictionary {
            self.detail = RCOrderDetail(json: detail)
        }
        if let product = json["product"]?.dictionary {
            self.product = RCProduct(json: product)
        }
        if let shipping = json["shipping"]?.dictionary {
            self.shipping = RCShipping(json: shipping)
        }
    }
}
