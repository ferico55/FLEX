//
//  TokoCashDateFilterViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashDateFilterViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let resetTrigger: Driver<Void>
        public let selectedItem: Driver<IndexPath>
        public let applyTrigger: Driver<Void>
        public let fromDate: Driver<Date>
        public let toDate: Driver<Date>
        public let isDateRange: Driver<Bool>
    }
    
    public struct Output {
        public let items: Driver<[TokoCashDateRangeItemViewModel]>
        public let fromDate: Driver<Date>
        public let fromDateMax: Driver<Date>
        public let fromDateString: Driver<String>
        public let toDate: Driver<Date>
        public let toDateMax: Driver<Date>
        public let toDateString: Driver<String>
        public let apply: Driver<DateFilter>
    }
    
    private var selectedDateRange: TokoCashDateRangeItem
    private var fromDate: Date
    private var toDate: Date
    private let navigator: TokoCashDateFilterNavigator
    private var dateRange: [TokoCashDateRangeItem] = {
        var arr: [TokoCashDateRangeItem] = []
        arr.append(TokoCashDateRangeItem("Hari Ini", fromDate: Date(), toDate: Date(), selected: false))
        arr.append(TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: false))
        arr.append(TokoCashDateRangeItem("30 Hari Terakhir", fromDate: Date.aMonthAgo(), toDate: Date(), selected: false))
        arr.append(TokoCashDateRangeItem("Bulan Ini", fromDate: Date.firstDayOfThisMonth(), toDate: Date.lastDayOfThisMonth(), selected: false))
        arr.append(TokoCashDateRangeItem("Bulan Lalu", fromDate: Date.firstDayOfLastMonth(), toDate: Date.lastDayOfLastMonth(), selected: false))
        return arr
    }()
    
    public init(selectedDateRange: TokoCashDateRangeItem, fromDate: Date, toDate: Date, navigator: TokoCashDateFilterNavigator) {
        self.selectedDateRange = selectedDateRange
        self.fromDate = fromDate
        self.toDate = toDate
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let selectedRange = Driver.of(self.selectedDateRange)
        
        let toDate = Driver.merge(Driver.merge(input.trigger, input.resetTrigger).flatMapLatest { return Driver.of(self.toDate) }, input.toDate)
        
        let toDateMax = toDate.map { _ -> Date in
            return Date()
        }
        
        let toDateString = toDate.map { toDate -> String in
            return toDate.tpDateFormat2()
        }
        
        let fromDate = Driver.merge(Driver.merge(input.trigger, input.resetTrigger).flatMapLatest { return Driver.of(self.fromDate) }, input.fromDate)
        
        let changeFromDate = toDate.withLatestFrom(fromDate) { (toDate, fromDate) -> Date in
            guard fromDate <= toDate else { return toDate }
            return fromDate
        }
        
        let fromDateMax = toDate.map { toDate -> Date in
            return toDate
        }
        
        let fromDateString = Driver.merge(fromDate, changeFromDate).map { fromDate -> String in
            return fromDate.tpDateFormat2()
        }
        
        let dateRanges = Driver.merge(input.trigger, input.resetTrigger).withLatestFrom(Driver.combineLatest(Driver.of(dateRange), selectedRange)) { _, data -> [TokoCashDateRangeItem] in
            var (dateRanges, selected) = data
            for i in 0 ..< dateRanges.count {
                if dateRanges[i].title == selected.title {
                    dateRanges[i].selected = selected.selected
                }
            }
            return dateRanges
        }
        
        let selectedItems = input.selectedItem.withLatestFrom(dateRanges) { indexPath, dateRanges -> [TokoCashDateRangeItem] in
            var items = dateRanges
            for i in 0 ..< items.count {
                if i == indexPath.row {
                    items[i].selected = true
                } else {
                    items[i].selected = false
                }
            }
            return items
        }
        
        let items = Driver.merge(dateRanges, selectedItems)
        
        let itemsViewModel = items.map { $0.map { TokoCashDateRangeItemViewModel(with: $0) } }
        
        let selectedItem = input.applyTrigger.withLatestFrom(items)
            .map { (items) -> TokoCashDateRangeItem in
                return items.first(where: { (item) -> Bool in item.selected })!
        }
        
        let apply = Driver.combineLatest(input.isDateRange, selectedItem, Driver.merge(fromDate, changeFromDate), toDate)
            .map { (isDateRange, selectedDate, fromDate, toDate) -> DateFilter in
                var fromDate = fromDate
                var toDate = toDate
                if isDateRange {
                    fromDate = selectedDate.fromDate
                    toDate = selectedDate.toDate
                }
                return DateFilter(selectedDateRange: selectedDate, fromDate: fromDate, toDate: toDate)
            }.do(onNext: { _ in self.navigator.backToPreviousController() })
        
        return Output(items: itemsViewModel,
                      fromDate: fromDate,
                      fromDateMax: fromDateMax,
                      fromDateString: fromDateString,
                      toDate: toDate,
                      toDateMax: toDateMax,
                      toDateString: toDateString,
                      apply: apply)
    }
}
