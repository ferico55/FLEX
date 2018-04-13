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

internal final class DigitalCart:Unboxable {
    internal var cartId = ""
    internal var productId = ""
    internal var categoryId = ""
    internal var userId = ""
    internal var clientNumber = ""
    internal var title = ""
    internal var categoryName = ""
    internal var operatorName = ""
    internal var icon = ""
    internal var priceText = ""
    internal var price:Double = 0
    internal var instantCheckout = false
    internal var needOTP = false
    internal var smsState = ""
    internal var voucherCode = ""
    internal var mainInfo = [DigitalCartInfoDetail]()
    internal var additionalInfo:[DigitalCartInfo]?
    internal var userInputPrice:DigitalCartUserInputPrice?
    internal var isCouponActive = ""
    internal var autoCode:AutoCode?
    internal var defaultTab = ""
    
    internal init(cartId:String = "", productId:String = "", categoryId:String = "", userId:String = "", clientNumber:String = "", title:String = "", categoryName:String = "", operatorName:String = "", icon:String = "", priceText:String = "", price:Double = 0.0, instantCheckout:Bool = false, needOTP:Bool = false, smsState:String = "", voucherCode:String = "", mainInfo:[DigitalCartInfoDetail] = [], additionalInfo:[DigitalCartInfo]? = nil, userInputPrice:DigitalCartUserInputPrice? = nil, isCouponActive: String = "", autoCode:AutoCode? = nil, defaultTab: String = "") {
        self.cartId = cartId
        self.productId = productId
        self.categoryId = categoryId
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
        self.isCouponActive = isCouponActive
        self.autoCode = autoCode
        self.defaultTab = defaultTab
    }
    
    internal convenience init(unboxer: Unboxer) throws {
        let cartId = try unboxer.unbox(keyPath: "data.id") as String
        let productId = try unboxer.unbox(keyPath: "data.relationships.product.data.id") as String
        let categoryId = try unboxer.unbox(keyPath: "data.relationships.category.data.id") as String
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
        let isCouponActive = try? unboxer.unbox(keyPath: "data.attributes.is_coupon_active") as String
        let autoCode = try? unboxer.unbox(keyPath: "data.attributes.autoapply") as AutoCode
        let defaultTab = try? unboxer.unbox(keyPath: "data.attributes.default_promo_dialog_tab") as String
        
        self.init(cartId:cartId,
                  productId:productId,
                  categoryId:categoryId,
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
                  userInputPrice:userInputPrice,
                  isCouponActive:isCouponActive ?? "0",
                  autoCode:autoCode,
                  defaultTab: defaultTab ?? "voucher")
    }
}
