//
//  RCTrouble.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCTrouble: NSObject {
    var id: Int = 0
    var name: String = ""
//    MARK:- User values
    override init(){}
    init(json:JSON) {
        if let id = json["id"].int {
            self.id = id
        }
        if let name = json["name"].string {
            self.name = name
        }
    }
}
