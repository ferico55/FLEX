//
//  ComplaintQuickFilterData.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 02/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

internal struct ComplaintQuickFilterData {
    internal let title: String
    internal let fullTitle: String
    internal let value: String
    internal var isSelected = false
    
    internal init(title: String, fullTitle: String, value: String) {
        self.title = title
        self.fullTitle = fullTitle
        self.value = value
    }
}

extension ComplaintQuickFilterData : JSONAbleType {
    internal static func fromJSON(_ source: [String: Any]) -> ComplaintQuickFilterData {
        let json = JSON(source)
        
        let title = json["titleCountFullString"].stringValue
        let fullTitle = json["filterWithDateString"].stringValue
        let value = json["orderValue"].stringValue
        
        return ComplaintQuickFilterData(title: title, fullTitle: fullTitle, value: value)
    }
}
