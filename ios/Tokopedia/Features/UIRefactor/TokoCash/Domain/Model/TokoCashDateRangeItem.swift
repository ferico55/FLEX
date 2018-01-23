//
//  TokoCashDateRangeItem.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 21/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

struct TokoCashDateRangeItem {
    let title: String
    let fromDate: Date
    let toDate: Date
    var selected: Bool
    
    init(_ title: String, fromDate: Date, toDate: Date, selected: Bool) {
        self.title = title
        self.fromDate = fromDate
        self.toDate = toDate
        self.selected = selected
    }
}

