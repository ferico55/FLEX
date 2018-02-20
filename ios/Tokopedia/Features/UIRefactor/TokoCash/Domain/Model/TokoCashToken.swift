//
//  TokoCashToken.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TokoCashToken {
    public let status: String?
    public let serverProcessTime: String?
    public let config: String?
    public let error: String?
    public let errorDescription: String?
    public let token: String?
}

extension TokoCashToken: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.status = try? unboxer.unbox(keyPath: "status")
        self.serverProcessTime = try? unboxer.unbox(keyPath: "serverProcessTime")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.error = try? unboxer.unbox(keyPath: "error")
        self.errorDescription = try? unboxer.unbox(keyPath: "error_description")
        self.token = try? unboxer.unbox(keyPath: "data.token")
    }
}
