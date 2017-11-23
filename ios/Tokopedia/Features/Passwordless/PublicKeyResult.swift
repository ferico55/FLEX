//
//  PublicKeyResult.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class PublicKeyResult: Unboxable {
    var isSuccess = false

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    convenience init(unboxer: Unboxer) throws {
        let isSuccess = try unboxer.unbox(keyPath: "data.is_success") as Int

        self.init(isSuccess: isSuccess == 1 ? true : false)
    }
}
