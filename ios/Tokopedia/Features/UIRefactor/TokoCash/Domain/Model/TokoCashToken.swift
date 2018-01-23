//
//  TokoCashToken.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashToken {
    let status: String?
    let serverProcessTime: String?
    let config: String?
    let error: String?
    let error_description: String?
    let token: String?
}

extension TokoCashToken: Unboxable {
    init(unboxer: Unboxer) throws {
        self.status = try? unboxer.unbox(keyPath: "status")
        self.serverProcessTime = try? unboxer.unbox(keyPath: "serverProcessTime")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.error = try? unboxer.unbox(keyPath: "error")
        self.error_description = try? unboxer.unbox(keyPath: "error_description")
        self.token = try? unboxer.unbox(keyPath: "data.token")
    }
}
