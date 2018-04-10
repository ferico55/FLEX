//
//  TokoCashPayment.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashPaymentResponse {
    public let code: String?
    public let message: String?
    public let errors: String?
    public let config: String?
    public let data: TokoCashPayment?
}

extension TokoCashPaymentResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct TokoCashPayment {
    public let paymentId: String?
    public let status: String?
    public let transactionId: String?
    public let datetime: String?
    public let logo: String?
    public let balance: Int?
    
    public var amount: Int?
    public var merchantName: String?
}

extension TokoCashPayment: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.paymentId = try? unboxer.unbox(keyPath: "payment_id")
        self.status = try? unboxer.unbox(keyPath: "status")
        self.transactionId = try? unboxer.unbox(keyPath: "transaction_id")
        self.datetime = try? unboxer.unbox(key: "datetime")
        self.logo = try? unboxer.unbox(keyPath: "logo")
        self.balance = try? unboxer.unbox(keyPath: "amount")
    }
}
