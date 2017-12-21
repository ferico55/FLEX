//
//  RCCreateSolutionResponse.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCCreateSolutionResponse: NSObject {
    var status: String = ""
    var data: RCCreateSolutionData = RCCreateSolutionData()
    var message_error: [String] = []
    override init(){}
    init(json:JSON) {
        if let status = json["status"].string {
            self.status = status
        }
        if let data = json["data"].dictionary {
            self.data = RCCreateSolutionData(json:data)
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
