//
//  DigitalCartPayment.swift
//  Tokopedia
//
//  Created by Ronald on 3/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class DigitalCartPayment:Unboxable {
    var redirectUrl:String
    var callbackUrlSuccess:String
    var callbackUrlFailed:String
    var queryString:String
    var transactionId:String
//    var errorMessage:String?
//    var merchantCode:String
//    var profileCode:String
//    var transactionCode:String
//    var transactionDate:String
//    var customerName:String
//    var customerEmail:String
//    var amoun:Double
//    var currency:String
//    var name:[String]
//    var qty:[Int]
//    var price:[Double]
//    var signature:String
//    var language:String
//    var userDefinedValue:String
//    var nid:String
//    var state:String
//    var fee:String
//    var amount:[String]
//    var voucher:[String]
//    var pid:String

    init(redirectUrl: String, callbackUrlSuccess: String, callbackUrlFailed: String, queryString: String, transactionId: String) {
        self.redirectUrl = redirectUrl
        self.callbackUrlSuccess = callbackUrlSuccess
        self.callbackUrlFailed = callbackUrlFailed
        self.queryString = queryString
        self.transactionId = transactionId
//        self.errorMessage = errorMessage
    }
    
    convenience init(unboxer: Unboxer) throws {
        let redirectUrl = try unboxer.unbox(keyPath: "data.attributes.redirect_url") as String
        let callbackUrlSuccess = try unboxer.unbox(keyPath: "data.attributes.callback_url_success") as String
        let callbackUrlFailed = try unboxer.unbox(keyPath: "data.attributes.callback_url_failed") as String
        let queryString = try unboxer.unbox(keyPath: "data.attributes.query_string") as String
        let transactionId = try unboxer.unbox(keyPath: "data.attributes.parameter.transaction_id") as String
//        let errorMessage = try unboxer.unbox(keyPath: "errors.title") as String
        
        self.init(redirectUrl: redirectUrl, callbackUrlSuccess: callbackUrlSuccess, callbackUrlFailed: callbackUrlFailed, queryString: queryString, transactionId: transactionId)
    }

}
