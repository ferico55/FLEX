//
//  RCCreateComplaintResponse.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import SwiftyJSON
class RCCreateComplaintResponse: NSObject {
    var status: String = ""
    var data: RCCreateComplaintResponseData?
    var message_error: [String] = []
    override init(){}
    init(json:JSON) {
        if let status = json["status"].string {
            self.status = status
        }
        if let data = json["data"].dictionary {
            self.data = RCCreateComplaintResponseData(json:data)
        }
        if let list = json["messageError"].array {
            for item in list {
                if let error = item.string {
                    self.message_error.append(error)
                }
            }
        }
    }
}
