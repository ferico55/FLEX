//
//  TokoCashDateRangeItem.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 21/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

public struct DateFilter {
    public let selectedDateRange: TokoCashDateRangeItem
    public let fromDate: Date
    public let toDate: Date
    
    public init(selectedDateRange: TokoCashDateRangeItem, fromDate: Date, toDate: Date) {
        self.selectedDateRange = selectedDateRange
        self.fromDate = fromDate
        self.toDate = toDate
    }
}

public struct TokoCashDateRangeItem {
    public let title: String
    public let fromDate: Date
    public let toDate: Date
    public var selected: Bool
    
    public init(_ title: String, fromDate: Date, toDate: Date, selected: Bool) {
        self.title = title
        self.fromDate = fromDate
        self.toDate = toDate
        self.selected = selected
    }
}

