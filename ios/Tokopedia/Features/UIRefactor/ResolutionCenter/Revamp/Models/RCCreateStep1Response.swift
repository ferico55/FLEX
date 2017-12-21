//
//  RCCreateStep1Response.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCCreateStep1Response: NSObject {
    var status: String = ""
    var data: RCCreateStep1ResponseData = RCCreateStep1ResponseData()
    var message_error: [String] = []
    override init(){}
    init(json:JSON) {
        if let status = json["status"].string {
            self.status = status
        }
        if let data = json["data"].dictionary {
            self.data = RCCreateStep1ResponseData(json:data)
        }
        if let list = json["message_error"].array {
            for item in list {
                if let error = item.string {
                    self.message_error.append(error)
                }
            }
        }
    }
}
