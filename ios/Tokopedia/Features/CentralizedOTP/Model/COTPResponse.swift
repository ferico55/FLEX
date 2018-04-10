//
//  COTPResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 30/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

public class COTPResponse: NSObject {
    public let status: String
    public let messageSuccess: [String]?
    public let messageError: [String]?
    public let isSuccess: Bool?
    public let uuid: String?

    public init(status: String, messageError: [String]?, messageSuccess: [String]?, isSuccess: Bool?, uuid: String?) {
        self.status = status
        self.messageSuccess = messageSuccess
        self.messageError = messageError
        self.isSuccess = isSuccess
        self.uuid = uuid
    }

    convenience public init(json: JSON) {
        var successMsgArr: [String]?
        var errorMsgArr: [String]?

        let status = json["status"].stringValue
        if let messageError = json["message_error"].array {
            errorMsgArr = [String]()
            for msg in messageError {
                errorMsgArr?.append(msg.stringValue)
            }
        }

        if let messageSuccess = json["message_status"].array {
            successMsgArr = [String]()
            for msg in messageSuccess {
                successMsgArr?.append(msg.stringValue)
            }
        }

        let isSuccess = json["data"]["is_success"].bool
        let uuid = json["data"]["uuid"].string

        self.init(status: status, messageError: errorMsgArr, messageSuccess: successMsgArr, isSuccess: isSuccess, uuid: uuid)
    }
}
