//
//  TriggerCampaign.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 31/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

public struct TriggerCampaignResponse {
    public let status: String?
    public let message: String?
    public let errors: String?
    public let config: String?
    public let data: String?
}

extension TriggerCampaignResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.status = try? unboxer.unbox(keyPath: "status")
        self.message = try? unboxer.unbox(keyPath: "message")
        self.errors = try? unboxer.unbox(keyPath: "errors")
        self.config = try? unboxer.unbox(keyPath: "config")
        self.data = try? unboxer.unbox(keyPath: "data.tkp_url")
    }
}
