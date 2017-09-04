//
//  OneClickUser.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

class OneClickData: Unboxable {

    var tokenID: String
    var credentialType: String
    var credentialNumber: String
    var maxLimit: String

    init(tokenID: String, credentialType: String, credentialNumber: String, maxLimit: String) {
        self.tokenID = tokenID
        self.credentialType = credentialType
        self.credentialNumber = credentialNumber
        self.maxLimit = maxLimit
    }

    convenience init() {
        self.init(
            tokenID: "",
            credentialType: "",
            credentialNumber: "",
            maxLimit: ""
        )
    }

    required convenience init(unboxer: Unboxer) throws {
        self.init(
            tokenID: try unboxer.unbox(keyPath: "token_id"),
            credentialType: try unboxer.unbox(keyPath: "credential_type"),
            credentialNumber: try unboxer.unbox(keyPath: "credential_no"),
            maxLimit: try unboxer.unbox(keyPath: "max_limit")
        )
    }
}
