//
//  TokoCashDateFilterViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TokoCashDateFilterDelegate {
    func getDateRange(_ selectedDateRange: TokoCashDateRangeItem, fromDate: Date, toDate: Date)
}

final class TokoCashDateFilterViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let resetTrigger: Driver<Void>
        let selectedItem: Driver<IndexPath>
        let applyTrigger: Driver<Void>
        let fromDate: Driver<Date>
        let toDate: Driver<Date>
        let isDateRange: Driver<Bool>
    }
    
    struct Output {
        let items: Driver<[TokoCashDateRangeItemViewModel]>
        let fromDate: Driver<Date>
        let fromDateMax: Driver<Date>
        let fromDateString: Driver<String>
        let toDate: Driver<Date>
        let toDateMax: Driver<Date>
        let toDateString: Driver<String>
        let apply: Driver<Void>
    }
    
    var delegate: TokoCashDateFilterDelegate?
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
    
    init(selectedDateRange: TokoCashDateRangeItem, fromDate: Date, toDate: Date, navigator: TokoCashDateFilterNavigator) {
        self.selectedDateRange = selectedDateRange
        self.fromDate = fromDate
        self.toDate = toDate
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        
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
            .do(onNext: { isDateRange, selectedDate, fromDate, toDate in
                var fromDate = fromDate
                var toDate = toDate
                if isDateRange {
                    fromDate = selectedDate.fromDate
                    toDate = selectedDate.toDate
                }
                self.delegate?.getDateRange(selectedDate, fromDate: fromDate, toDate: toDate)
                self.navigator.backToPreviousController()
            }).mapToVoid()
        
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
