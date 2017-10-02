//
//  RegisterUnbox.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox
import Foundation

struct RegisterUnbox {
    let userID: String?
    let isActive: Bool?
    let smartRegisterAction: SmartRegisterStatus?
    let isSuccess: Bool
    let errorMessages: [String]?
}

public enum SmartRegisterStatus: Int, UnboxableEnum {
    case defaultAction = 0
    case needActivation = 1
    case loginAutomatically = 2
    case resetPassword = 3
}

extension RegisterUnbox: Unboxable {
    init(unboxer: Unboxer) throws {
        self.userID = try? unboxer.unbox(keyPath: "data.u_id") as String
        self.isActive = try? unboxer.unbox(keyPath: "data.is_active") as Bool
        self.smartRegisterAction = try? unboxer.unbox(keyPath: "data.action") as SmartRegisterStatus
        self.isSuccess = try unboxer.unbox(keyPath: "data.is_success")
        self.errorMessages = try? unboxer.unbox(keyPath: "message_error") as [String]
    }
}
