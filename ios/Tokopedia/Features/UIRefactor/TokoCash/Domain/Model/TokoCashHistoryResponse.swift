//
//  TokoCashHistory.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashHistoryResponse {
    let code: String?
    let message: String?
    let errors: String?
    let config: String?
    let data: TokoCashHistory?
}

extension TokoCashHistoryResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}
