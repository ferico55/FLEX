//
//  DigitalCart.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class DigitalCart:NSObject {
    var userId = ""
    var clientNumber = ""
    var title = ""
    var categoryName = ""
    var operatorName = ""
    var icon = ""
    var priceText = ""
    var price:Double = 0
    var instantCheckout = false
    var needOTP = false
    var smsState = ""
    var mainInfo = [DigitalCartInfoDetail]()
    var additionalInfo:[DigitalCartInfo]?
    var userInputPrice:DigitalCartUserInputPrice?
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from:["user_id":"userId" , "client_number": "clientNumber", "title" : "title",  "category_name": "categoryName",  "operator_name": "operatorName", "icon" : "icon", "price" : "priceText", "price_plain" : "price", "instant_checkout" : "instantCheckout", "need_otp" : "needOTP", "sms_state" : "smsState"])
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "main_info", toKeyPath: "mainInfo", with: DigitalCartInfoDetail.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "additional_info", toKeyPath: "additionalInfo", with: DigitalCartInfo.mapping()))
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "user_input_price", toKeyPath: "userInputPrice", with: DigitalCartUserInputPrice.mapping()))
        return mapping
    }
}
