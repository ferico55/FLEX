//
//  RCFreeReturn.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCFreeReturn: NSObject {
    var info = ""
    var link = ""
    override init(){}
    //  MARK:- Mapping
    init(json:[String:JSON]) {
        if let info = json["info"]?.string {
            self.info = info
        }
        if let link = json["link"]?.string {
            self.link = link
        }
    }
}
