//
//  ResendActivationEmail.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox
import Foundation

struct ResendActivationEmail {
    let status: ResendActivationEmailStatus
    let statusMessages: [String]?
    let errorMessages: [String]?
}

public enum ResendActivationEmailStatus: Int, UnboxableEnum {
    case success = 1
    case alreadyRegistered = 2
    case unregistered = 0
    case invalid = -1
}

extension ResendActivationEmail: Unboxable {
    init(unboxer: Unboxer) throws {
        self.status = try unboxer.unbox(keyPath: "data.is_success") as ResendActivationEmailStatus
        self.statusMessages = try? unboxer.unbox(keyPath: "message_status") as [String]
        self.errorMessages = try? unboxer.unbox(keyPath: "message_error") as [String]
    }
}
