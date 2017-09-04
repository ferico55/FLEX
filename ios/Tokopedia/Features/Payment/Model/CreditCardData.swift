//
//  CreditCardData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

class CreditCardResponse: Unboxable {

    var list: [CreditCardData]?
    var success: Bool?

    init(list: [CreditCardData]?, success: Bool?) {
        self.list = list
        self.success = success
    }

    required convenience init(unboxer: Unboxer) throws {
        self.init(
            list: try? unboxer.unbox(keyPath: "data"),
            success: try? unboxer.unbox(keyPath: "success") as Bool
        )
    }
}

class CreditCardData: Unboxable {

    let tokenID: String
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cardType: String
    let imageURLString: String

    init(tokenID: String, number: String, expiryMonth: String, expiryYear: String, cardType: String, imageURLString: String) {
        self.tokenID = tokenID
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.cardType = cardType
        self.imageURLString = imageURLString
    }

    convenience init() {
        self.init(
            tokenID: "",
            number: "",
            expiryMonth: "",
            expiryYear: "",
            cardType: "",
            imageURLString: ""
        )
    }

    required convenience init(unboxer: Unboxer) throws {
        self.init(
            tokenID: try unboxer.unbox(keyPath: "token_id"),
            number: try unboxer.unbox(keyPath: "masked_number"),
            expiryMonth: try unboxer.unbox(keyPath: "expiry_month"),
            expiryYear: try unboxer.unbox(keyPath: "expiry_year"),
            cardType: try unboxer.unbox(keyPath: "card_type"),
            imageURLString: try unboxer.unbox(keyPath: "card_type_image")
        )
    }
}
