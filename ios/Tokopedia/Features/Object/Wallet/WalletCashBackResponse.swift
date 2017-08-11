//
//  WalletCashBackResponse.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class WalletCashBackResponse: NSObject {
    let code: String?
    let config: String?
    let message: String?
    let error: [String]?
    let data: WalletCashBack?

    init(code: String? = nil, config: String? = nil, message: String? = nil, error: [String]? = nil, data: WalletCashBack? = nil) {
        self.code = code
        self.config = config
        self.message = message
        self.error = error
        self.data = data
    }
}

extension WalletCashBackResponse: JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> WalletCashBackResponse {
        let json = JSON(source)

        let code = json["code"].stringValue
        let config = json["config"].stringValue
        let message = json["message"].string
        let error = json["errors"].arrayValue.map { $0.stringValue }
        var data: WalletCashBack?
        if let dictionary = json["data"].dictionaryObject {
            data = WalletCashBack.fromJSON(dictionary)
        }

        return WalletCashBackResponse(code: code, config: config, message: message, error: error, data: data)
    }
}
