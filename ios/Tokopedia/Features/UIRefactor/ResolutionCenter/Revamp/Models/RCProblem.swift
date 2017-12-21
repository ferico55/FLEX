//
//  RCProblem.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCProblem: NSObject {
    var type: Int = 0
    var name: String = ""
    override init(){}
    init(json:[String:JSON]) {
        if let type = json["type"]?.int {
            self.type = type
        }
        if let name = json["name"]?.string {
            self.name = name
        }
    }
}
