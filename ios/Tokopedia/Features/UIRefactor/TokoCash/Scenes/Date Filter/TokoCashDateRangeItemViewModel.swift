//
//  TokoCashDateRangeItemViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final public class TokoCashDateRangeItemViewModel {
    public let item: TokoCashDateRangeItem
    public let title: String
    public let desc: String
    public var selected: Bool

    public init(with item: TokoCashDateRangeItem) {
        self.item = item
        self.title = item.title
        self.selected = item.selected

        var dateDesc = "\(item.fromDate.tpDateFormat2())"
        if Calendar.current.compare(item.fromDate, to: item.toDate, toGranularity: .day) != .orderedSame {
            dateDesc.append(" - \(item.toDate.tpDateFormat2())")
        }
        self.desc = dateDesc
    }
}
