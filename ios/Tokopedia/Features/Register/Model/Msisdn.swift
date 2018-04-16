//
//  Msisdn.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 21/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct MsisdnResponse {
    public let status: String?
    public let messageError: [String]?
    public let isExist: Bool?
    public let numberView: String?
}

extension MsisdnResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.status = try? unboxer.unbox(keyPath: "status")
        self.messageError = try? unboxer.unbox(keyPath: "message_error")
        self.isExist = try? unboxer.unbox(keyPath: "data.isExist")
        self.numberView = try? unboxer.unbox(keyPath: "data.phone_view")
    }
}
