//
//  DigitalCart.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class DigitalCart:Unboxable {
    var cartId = ""
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
    var voucherCode = ""
    var mainInfo = [DigitalCartInfoDetail]()
    var additionalInfo:[DigitalCartInfo]?
    var userInputPrice:DigitalCartUserInputPrice?
    
    init(cartId:String = "", userId:String = "", clientNumber:String = "", title:String = "", categoryName:String = "", operatorName:String = "", icon:String = "", priceText:String = "", price:Double = 0.0, instantCheckout:Bool = false, needOTP:Bool = false, smsState:String = "", voucherCode:String = "", mainInfo:[DigitalCartInfoDetail] = [], additionalInfo:[DigitalCartInfo]? = nil, userInputPrice:DigitalCartUserInputPrice? = nil) {
        self.cartId = cartId
        self.userId = userId
        self.clientNumber = clientNumber
        self.title = title
        self.categoryName = categoryName
        self.operatorName = operatorName
        self.icon = icon
        self.priceText = priceText
        self.price = price
        self.instantCheckout = instantCheckout
        self.needOTP = needOTP
        self.smsState = smsState
        self.voucherCode = voucherCode
        self.mainInfo = mainInfo
        self.additionalInfo = additionalInfo
        self.userInputPrice = userInputPrice
    }
    
    convenience init(unboxer: Unboxer) throws {
        let cartId = try unboxer.unbox(keyPath: "data.id") as String
        let userId = try unboxer.unbox(keyPath: "data.attributes.user_id") as String
        let clientNumber = try unboxer.unbox(keyPath: "data.attributes.client_number") as String
        let title = try unboxer.unbox(keyPath: "data.attributes.title") as String
        let categoryName = try unboxer.unbox(keyPath: "data.attributes.category_name") as String
        let operatorName = try unboxer.unbox(keyPath: "data.attributes.operator_name") as String
        let icon = try unboxer.unbox(keyPath: "data.attributes.icon") as String
        let priceText = try unboxer.unbox(keyPath: "data.attributes.price") as String
        let price = try unboxer.unbox(keyPath: "data.attributes.price_plain") as Double
        let instantCheckout = try unboxer.unbox(keyPath: "data.attributes.instant_checkout") as Bool
        let needOTP = try unboxer.unbox(keyPath: "data.attributes.need_otp") as Bool
        let smsState = try unboxer.unbox(keyPath: "data.attributes.sms_state") as String
        let voucherCode = try unboxer.unbox(keyPath: "data.attributes.voucher_autocode") as String
        let mainInfo = try unboxer.unbox(keyPath: "data.attributes.main_info") as [DigitalCartInfoDetail]
        let additionalInfo = try? unboxer.unbox(keyPath: "data.attributes.additional_info") as [DigitalCartInfo]
        let userInputPrice = try? unboxer.unbox(keyPath: "data.attributes.user_input_price") as DigitalCartUserInputPrice
        
        self.init(cartId:cartId,
                  userId:userId,
                  clientNumber:clientNumber,
                  title:title,
                  categoryName:categoryName,
                  operatorName:operatorName,
                  icon:icon,
                  priceText:priceText,
                  price:price,
                  instantCheckout:instantCheckout,
                  needOTP:needOTP,
                  smsState:smsState,
                  voucherCode:voucherCode,
                  mainInfo:mainInfo,
                  additionalInfo:additionalInfo,
                  userInputPrice:userInputPrice)
    }
}
