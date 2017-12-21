//
//  RCCreateSolution.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCCreateSolution: NSObject {
    var id: Int = 0
    var name: String = ""
    var nameCustom: String = ""
    var amount: RCAmount?
//    MARK:- User Values
    var returnExpected: NSNumber?
    var isSelected = false
//    MARK:- Init
    override init(){}
    //  MARK:- Mapping
    init(json:JSON) {
        if let id = json["id"].int {
            self.id = id
        }
        if let name = json["name"].string {
            self.name = name
        }
        if let nameCustom = json["nameCustom"].string {
            self.nameCustom = nameCustom
        }
        if let amount = json["amount"].dictionary {
            self.amount = RCAmount(json: amount)
        }
    }
}
