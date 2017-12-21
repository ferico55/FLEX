//
//  RCCreateComplaintResponseData.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import SwiftyJSON
class RCCreateComplaintResponseData: NSObject {
    var cacheKey: String?
    var token: String?
    var resolutionId: Int?
    var shopName: String?
    var succesMessage: String?
    override init(){}
    init(json:[String:JSON]) {
        if let cacheKey = json["cacheKey"]?.string {
            self.cacheKey = cacheKey
        }
        if let token = json["token"]?.string {
            self.token = token
        }
        if let resoId = json["resolution"]?["id"].int {
            self.resolutionId = resoId
        }
        if let shopName = json["shop"]?["name"].string {
            self.shopName = shopName
        }
        if let succesMessage = json["successMessage"]?.string {
            self.succesMessage = succesMessage
        }
    }
}
