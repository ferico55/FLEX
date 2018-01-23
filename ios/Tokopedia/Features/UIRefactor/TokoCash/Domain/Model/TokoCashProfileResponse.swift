//
//  TokoCashProfileResponse.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

struct TokoCashProfileResponse {
    let code: String?
    let message: String?
    let errors: String?
    let config: String?
    let data: TokoCashProfile?
}

extension TokoCashProfileResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data")
    }
}

struct TokoCashResponse {
    let code: String?
    let message: String?
    let errors: String?
    let config: String?
}

extension TokoCashResponse: Unboxable {
    init(unboxer: Unboxer) throws {
        self.code = try? unboxer.unbox(keyPath: "code")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
    }
}
