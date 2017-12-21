//
//  RCCreateSolutionData.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
class RCCreateSolutionData: NSObject {
    var solution: [RCCreateSolution] = []
    var require: RCSolutionRequire = RCSolutionRequire()
    var freeReturn: RCFreeReturn?
//    MARK:- User values
    var selectedSolution: RCCreateSolution? {
        get {
            for item in self.solution {
                if item.isSelected {
                    return item
                }
            }
            return nil
        }
        set(sol) {
            for item in self.solution {
                if item.id == sol?.id {
                    item.isSelected = true
                } else {
                    item.isSelected = false
                }
            }
        }
    }
    //  MARK:- Mapping
    override init(){}
    init(json:[String:JSON]) {
        if let list = json["solution"]?.array {
            for item in list {
                let status = RCCreateSolution(json: item)
                self.solution.append(status)
            }
        }
        if let require = json["require"]?.dictionary {
            self.require = RCSolutionRequire(json:require)
        }
        if let freeReturn = json["freeReturn"]?.dictionary {
            self.freeReturn = RCFreeReturn(json: freeReturn)
        }
    }
}
