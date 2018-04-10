//
//  WalletCashBack.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final public class WalletCashBack: NSObject {
    public let amount: String?
    public let amountText: String?
    public let currency: String?
    
    public init(amount: String? = nil, amountText: String? = nil, currency: String? = nil) {
        self.amount = amount
        self.amountText = amountText
        self.currency = currency
    }
}

extension WalletCashBack: JSONAbleType {
    public static func fromJSON(_ source: [String: Any]) -> WalletCashBack {
        let json = JSON(source)
        
        let amount = json["amount"].stringValue
        let amountText = json["amount_text"].stringValue
        let currency = json["currency"].stringValue
        
        return WalletCashBack(amount: amount, amountText: amountText, currency: currency)
    }
}
