//
//  RegisterPhoneNumber.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 23/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct RegisterPhoneNumberResponse {
    public let messageError: [String]?
    public let data: RegisterPhoneNumber?
}

extension RegisterPhoneNumberResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.messageError = try? unboxer.unbox(keyPath: "message_error")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

public struct RegisterPhoneNumber {
    public let uID: String?
    public let isActive: String?
    public let action: String?
    public let isSuccess: String?
    public let tokenInfo: OAuthToken?
}

extension RegisterPhoneNumber: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.uID = try? unboxer.unbox(keyPath: "u_id")
        self.isActive = try? unboxer.unbox(keyPath: "is_active")
        self.action = try? unboxer.unbox(keyPath: "action")
        self.isSuccess = try? unboxer.unbox(keyPath: "is_success")
        self.tokenInfo = try? unboxer.unbox(keyPath: "t_info")
    }
}
