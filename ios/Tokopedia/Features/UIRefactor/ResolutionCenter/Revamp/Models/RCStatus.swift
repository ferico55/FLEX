//
//  RCStatus.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCStatus: NSObject {
    var delivered: Bool = false
    var name: String = ""
    var trouble: [RCTrouble] = []
    var info: RCStatusDeliveryInfo?
//    MARK:- User Values
    var selectedTrouble: RCTrouble?
    var userTypedTrouble: String?
    override init(){}
    init(json:JSON) {
        if let delivered = json["delivered"].bool {
            self.delivered = delivered
        }
        if let name = json["name"].string {
            self.name = name
        }
        if let dictList = json["trouble"].array {
            for subJson in dictList {
                let trouble = RCTrouble(json: subJson)
                self.trouble.append(trouble)
            }
        }
        if let info = json["info"].dictionary {
            self.info = RCStatusDeliveryInfo(json: info)
        }
    }
}
