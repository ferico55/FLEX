//
//  APIAction.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 7/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class APIAction: Unboxable {
    var serverProcessTime = ""
    var status = ""
    var config: String?
    var messageError: [String]?
    var feedbackID: String?
    var isSuccess = ""

    init(serverProcessTime: String, status: String, config: String? = nil, messageError: [String]? = nil, feedbackID: String? = nil, isSuccess: String) {
        self.serverProcessTime = serverProcessTime
        self.status = status
        self.config = config
        self.messageError = messageError
        self.feedbackID = feedbackID
        self.isSuccess = isSuccess
    }

    convenience init(unboxer: Unboxer) throws {
        let serverProcessTime = try unboxer.unbox(keyPath: "server_process_time") as String
        let status = try unboxer.unbox(keyPath: "status") as String
        let config = try? unboxer.unbox(keyPath: "config") as String
        let messageError = try? unboxer.unbox(keyPath: "message_error") as [String]
        let feedbackID = try? unboxer.unbox(keyPath: "data.feedback_id") as String
        let isSuccess = try unboxer.unbox(keyPath: "data.is_success") as String

        self.init(serverProcessTime: serverProcessTime, status: status, config: config, messageError: messageError, feedbackID: feedbackID, isSuccess: isSuccess)
    }
}
