//
//  CreditCardData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

public class CreditCardResponse: Unboxable {

    public var list: [CreditCardData]?
    public var success: Bool?

    public init(list: [CreditCardData]?, success: Bool?) {
        self.list = list
        self.success = success
    }

    required convenience public init(unboxer: Unboxer) throws {
        self.init(
            list: try? unboxer.unbox(keyPath: "data"),
            success: try? unboxer.unbox(keyPath: "success") as Bool
        )
    }
}

public struct CreditCardData {
    public let tokenID: String
    public let number: String
    public let expiryMonth: String
    public let expiryYear: String
    public let cardType: String
    public let imageURLString: String
    public let isRegisteredFingerprint: Bool
    public let smallBackgroundImage: String
    public let backgroundImage: String
}

extension CreditCardData: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.tokenID = try unboxer.unbox(keyPath: "token_id")
        self.number = try unboxer.unbox(keyPath: "masked_number")
        self.expiryMonth = try unboxer.unbox(keyPath: "expiry_month")
        self.expiryYear = try unboxer.unbox(keyPath: "expiry_year")
        self.cardType = try unboxer.unbox(keyPath: "card_type")
        self.imageURLString = try unboxer.unbox(keyPath: "card_type_image")
        self.isRegisteredFingerprint = try unboxer.unbox(keyPath: "is_registered_fingerprint")
        self.smallBackgroundImage = try unboxer.unbox(keyPath: "small_background_image")
        self.backgroundImage = try unboxer.unbox(keyPath: "background_image")
    }
}

