//
//  ComplaintData.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 02/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

final internal class ComplaintData : NSObject {
    internal let inboxes: [ComplaintInbox]
    internal let quickFilters: [ComplaintQuickFilterData]
    internal let canLoadMore: Bool
    
    internal init(inboxes: [ComplaintInbox], quickFilters: [ComplaintQuickFilterData], canLoadMore: Bool) {
        self.inboxes = inboxes
        self.quickFilters = quickFilters
        self.canLoadMore = canLoadMore
    }
}

extension ComplaintData : JSONAbleType {
    internal static func fromJSON(_ source: [String: Any]) -> ComplaintData {
        let json = JSON(source)
        
        let data = json["data"]
        
        let inboxes = data["inboxes"].arrayValue.map { (json) -> ComplaintInbox in
            return ComplaintInbox.fromJSON(json.dictionaryValue)
        }
        let quickFilters = data["quickFilter"].arrayValue.map { (json) -> ComplaintQuickFilterData in
            return ComplaintQuickFilterData.fromJSON(json.dictionaryValue)
        }
        let canLoadMore = data["canLoadMore"].boolValue
        
        return ComplaintData(inboxes: inboxes, quickFilters: quickFilters, canLoadMore: canLoadMore)
    }
}
