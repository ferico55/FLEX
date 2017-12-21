//
//  RCSolutionRequire.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCSolutionRequire: NSObject {
    var attachment = false
    override init(){}
    //  MARK:- Mapping
    init(json:[String:JSON]) {
        if let attachment = json["attachment"]?.bool {
            self.attachment = attachment
        }
    }
}
