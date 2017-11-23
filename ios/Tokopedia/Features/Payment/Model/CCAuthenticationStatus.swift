//
//  CCAuthenticationStatus.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CCAuthenticationStatus: Unboxable {

    var state: Int?
    var statusCode: Int?
    var message: String?

    init(state: Int? = 0, message: String? = "", statusCode: Int? = 0) {
        self.state = state
        self.message = message
        self.statusCode = statusCode
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            state: unboxer.unbox(keyPath: "data.0.state"),
            message: unboxer.unbox(keyPath: "message"),
            statusCode: unboxer.unbox(keyPath: "status_code")
        )
    }
}
