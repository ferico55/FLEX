//
//  OneClickAuth.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class OneClickAuth: Unboxable {

    var success = false
    var message: String?
    var token: OneClickAuthToken?

    init(success: Bool, message: String?, token: OneClickAuthToken?) {
        self.success = success
        self.message = message
        self.token = token
    }
    
    convenience init() {
        self.init(success: false, message: nil, token: nil)
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            success: try unboxer.unbox(keyPath: "success"),
            message: try? unboxer.unbox(keyPath: "message"),
            token: try? unboxer.unbox(keyPath: "data.token")
        )
    }
}

final class OneClickAuthToken: Unboxable {

    var accessToken: String?

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            accessToken: try unboxer.unbox(keyPath: "access_token")
        )
    }
}
