//
//  PaymentActionResponse.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Unbox

final class PaymentActionResponse: Unboxable {

    var success = false
    var message: String?

    init(success: Bool, message: String?) {
        self.success = success
        self.message = message
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            success: try unboxer.unbox(keyPath: "success"),
            message: try? unboxer.unbox(keyPath: "message")
        )
    }
}
