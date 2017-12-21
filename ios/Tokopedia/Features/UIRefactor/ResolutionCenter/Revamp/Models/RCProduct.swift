//
//  RCProduct.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCProduct: NSObject {
    var name: String = ""
    var thumb: String = ""
    var variant: String = ""
    var quantity: Int = 0
    var amount: RCAmount = RCAmount()
    override init(){}
    init(json:[String:JSON]) {
        if let name = json["name"]?.string {
            self.name = name
        }
        if let thumb = json["thumb"]?.string {
            self.thumb = thumb
        }
        if let variant = json["variant"]?.string {
            self.variant = variant
        }
        if let quantity = json["quantity"]?.int {
            self.quantity = quantity
        }
        if let item = json["amount"]?.dictionary {
            self.amount = RCAmount(json: item)
        }
    }
}
