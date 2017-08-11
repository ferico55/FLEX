//
//  WalletCashBack.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class WalletCashBack: NSObject {
    let amount: String?
    let amountText: String?
    let currency: String?

    init(amount: String? = nil, amountText: String? = nil, currency: String? = nil) {
        self.amount = amount
        self.amountText = amountText
        self.currency = currency
    }
}

extension WalletCashBack: JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> WalletCashBack {
        let json = JSON(source)

        let amount = json["amount"].stringValue
        let amountText = json["amount_text"].stringValue
        let currency = json["currency"].stringValue

        return WalletCashBack(amount: amount, amountText: amountText, currency: currency)
    }
}
