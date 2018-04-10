//
//  TokoCashQRInfo.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 30/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashQRInfoResponse {
    public let code: String?
    public let message: String?
    public let errors: String?
    public let config: String?
    public var data: TokoCashQRInfo?
}

extension TokoCashQRInfoResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct TokoCashQRInfo {
    public let name: String?
    public let email: String?
    public let phoneNumber: String?
    public let amount: Int?
    
    public var merchantIdentifier: String?
}

extension TokoCashQRInfo: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.name = try? unboxer.unbox(keyPath: "name")
        self.email = try? unboxer.unbox(keyPath: "email")
        self.phoneNumber = try? unboxer.unbox(keyPath: "phone_number")
        self.amount = try? unboxer.unbox(keyPath: "amount")
    }
}
