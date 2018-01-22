//
//  RCProblemItem.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
final class RCProblemItem: NSObject {
    var problem: RCProblem = RCProblem()
    var order: RCOrder?
    var status: [RCStatus] = []
//    MARK:- User Values
    var isSelected = false
    var goodsCount = 0
    var selectedStatus: RCStatus?
    var remark: String?
    func setSelectedStatus(isDeliveredType: Bool) {
        for item in self.status {
            if item.delivered == isDeliveredType {
                if isDeliveredType {
                    item.selectedTrouble = nil
                } else {
                    item.selectedTrouble = item.trouble.first
                }
                self.selectedStatus = item
                break
            }
        }
    }
    func getStatus(isDelivered: Bool)->RCStatus? {
        return self.status.filter({ (status: RCStatus) -> Bool in
            return status.delivered == isDelivered
        }).first
        
    }
    override init(){}
    init(json:JSON) {
        if let problem = json["problem"].dictionary {
            self.problem = RCProblem(json: problem)
        }
        if let order = json["order"].dictionary {
            self.order = RCOrder(json:order)
        }
        if let statusList = json["status"].array {
            for item in statusList {
                let status = RCStatus(json: item)
                self.status.append(status)
            }
        }
    }
}
