//
//  TokoCashQRInfo.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 30/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashQRInfoResponse {
    let code: String?
    let message: String?
    let errors: String?
    let config: String?
    var data: TokoCashQRInfo?
}

extension TokoCashQRInfoResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

struct TokoCashQRInfo {
    let name: String?
    let email: String?
    let phoneNumber: String?
    let amount: Int?
    
    var merchantIdentifier: String?
}

extension TokoCashQRInfo: Unboxable {
    init(unboxer: Unboxer) throws {
        self.name = try? unboxer.unbox(keyPath: "name")
        self.email = try? unboxer.unbox(keyPath: "email")
        self.phoneNumber = try? unboxer.unbox(keyPath: "phone_number")
        self.amount = try? unboxer.unbox(keyPath: "amount")
    }
}
