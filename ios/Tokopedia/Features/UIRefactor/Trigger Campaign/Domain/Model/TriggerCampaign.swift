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
    public let errorMessage: [String]?
    public let data: String?
}

extension TriggerCampaignResponse: Unboxable {
    public init(unboxer: Unboxer) throws {
        self.status = try? unboxer.unbox(keyPath: "status")
        self.errorMessage = try? unboxer.unbox(keyPath: "message_error")
        self.data = try? unboxer.unbox(keyPath: "data.tkp_url")
    }
}
