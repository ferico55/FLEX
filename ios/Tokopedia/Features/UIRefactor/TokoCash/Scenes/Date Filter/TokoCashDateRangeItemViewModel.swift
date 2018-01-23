//
//  TokoCashDateRangeItemViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashDateRangeItemViewModel {
    let item: TokoCashDateRangeItem
    let title: String
    let desc: String
    var selected: Bool
    
    init(with item: TokoCashDateRangeItem) {
        self.item = item
        self.title = item.title
        self.selected = item.selected
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        var dateDesc = "\(dateFormatter.string(from: item.fromDate))"
        if (item.fromDate != item.toDate) {
            dateDesc.append(" - \(dateFormatter.string(from: item.toDate))")
        }
        self.desc = dateDesc
    }
}
