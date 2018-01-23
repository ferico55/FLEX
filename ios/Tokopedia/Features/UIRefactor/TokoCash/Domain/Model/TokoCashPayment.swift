//
//  TokoCashPayment.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashPaymentResponse {
    let code: String?
    let message: String?
    let errors: String?
    let config: String?
    let data: TokoCashPayment?
}

extension TokoCashPaymentResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

struct TokoCashPayment {
    let payment_id: String?
    let status: String?
    let transaction_id: String?
    let datetime: String?
    let logo: String?
    let balance: Int?
    
    var amount: Int?
    var merchantName: String?
}

extension TokoCashPayment: Unboxable {
    init(unboxer: Unboxer) throws {
        self.payment_id = try? unboxer.unbox(keyPath: "payment_id")
        self.status = try? unboxer.unbox(keyPath: "status")
        self.transaction_id = try? unboxer.unbox(keyPath: "transaction_id")
        self.datetime = try? unboxer.unbox(key: "datetime")
        self.logo = try? unboxer.unbox(keyPath: "logo")
        self.balance = try? unboxer.unbox(keyPath: "amount")
    }
}
