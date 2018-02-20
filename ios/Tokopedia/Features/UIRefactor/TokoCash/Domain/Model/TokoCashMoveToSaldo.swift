//
//  TokoCashMoveToSaldo.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 29/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashMoveToSaldoResponse {
    public let code: String?
    public let message: String?
    public let config: String?
    public let errors: [String]?
    public let data: TokoCashMoveToSaldo?
    
}

extension TokoCashMoveToSaldoResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct TokoCashMoveToSaldo {
    public let amount: Int?
    public let email: String?
    public let withdrawalId: String?
}

extension TokoCashMoveToSaldo: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.amount = try? unboxer.unbox(keyPath: "amount")
        self.email = try? unboxer.unbox(keyPath: "dest_email")
        self.withdrawalId = try? unboxer.unbox(keyPath: "withdrawal_id")
    }
}
