//
//  TokoCashWalletHistoryListViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

final public class TokoCashHistoryListViewModel: ViewModelType {
    
    public struct Input {
        public let trigger: Driver<Void>
        public let pullTrigger: Driver<Void>
        public let pendingTransactionTrigger: Driver<Void>
        public let dateFilterTrigger: Driver<Void>
        public let filter: Driver<IndexPath>
        public let selection: Driver<IndexPath>
        public let nextPageTrigger: Driver<Void>
    }
    
    public struct Output {
        public let fetching: Driver<Bool>
        public let tokoCashHistory: Driver<TokoCashHistoryResponse>
        public let showPendingTransaction: Driver<Bool>
        public let pendingTransaction: Driver<[TokoCashHistoryItems]>
        public let dateString: Driver<String>
        public let dateFilter: Driver<DateFilter>
        public let headers: Driver<[TokoCashFilterViewModel]>
        public let showHeader: Driver<Bool>
        public let items: Driver<[TokoCashHistoryListItemViewModel]>
        public let isEmptyState: Driver<Bool>
        public let emptyState: Driver<String>
        public let selectedItem: Driver<TokoCashHistoryItems>
        public let page: Driver<Int>
    }
    
    private let dateRange = Variable(TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: true))
    private let startDate = Variable(Date.aWeekAgo())
    private let endDate = Variable(Date())
    
    private var navigator: TokoCashHistoryListNavigator
    
    public init(navigator: TokoCashHistoryListNavigator) {
        self.navigator = navigator
    }
    
    public func transform(input: Input) -> Output {
        
        let items = Variable([TokoCashHistoryItems]())
        let page = Variable(1)
        let nextUri = Variable(false)
        let typea = Variable("all")
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        // pending transaction
        let tokoCashPendingTrasactionResponse = input.trigger.flatMapLatest { _ in
            return TokoCashUseCase.getWalletHistory(historyType: "pending")
                .asDriverOnErrorJustComplete()
        }
        
        let pendingTransaction = tokoCashPendingTrasactionResponse.map { tokoCashPendingTrasactionResponse -> [TokoCashHistoryItems] in
            return tokoCashPendingTrasactionResponse.data?.items ?? [TokoCashHistoryItems]()
        }
        
        let showPendingTransaction = pendingTransaction.map { pendingTransaction -> Bool in
            pendingTransaction.count == 0
        }.startWith(true)
        
        let pendingTransactionTap = input.pendingTransactionTrigger.withLatestFrom(pendingTransaction)
            .do(onNext: navigator.toPendingTransaction)
        
        // date filter
        let dateData = Driver.combineLatest(dateRange.asDriver(), startDate.asDriver(), endDate.asDriver())
        let dateFilter = input.dateFilterTrigger.withLatestFrom(dateData)
            .flatMapLatest { data -> SharedSequence<DriverSharingStrategy, DateFilter> in
                let (dateRange, startDate, endDate) = data
                let vc = self.navigator.toDateFilter(dateRange: dateRange, fromDate: startDate, toDate: endDate)
                return vc.dateFilter.asDriverOnErrorJustComplete()
            }.do(onNext: { dataFilter in
                self.dateRange.value = dataFilter.selectedDateRange
                self.startDate.value = dataFilter.fromDate
                self.endDate.value = dataFilter.toDate
            })
        
        let dateString = Driver.combineLatest(startDate.asDriver(), endDate.asDriver(), resultSelector: { (startDate, endDate) -> String in
            guard Calendar.current.compare(startDate, to: endDate,toGranularity: .day) == .orderedSame else {
                return "\(startDate.tpDateFormat2()) - \(endDate.tpDateFormat2())"
            }
            return startDate.tpDateFormat2()
        })
        
        // history data
        let loadData = Driver.merge(input.pullTrigger, typea.asDriver().distinctUntilChanged().mapToVoid(), dateFilter.mapToVoid())
            .do(onNext: { _ in
                page.value = 1
                items.value = [TokoCashHistoryItems]()
            })
        
        let nextPageConstraint = Driver.combineLatest(activityIndicator.asDriver(), nextUri.asDriver())
        let nextPage = input.nextPageTrigger.withLatestFrom(nextPageConstraint)
            .flatMapLatest { (activityIndicator, nextUri) -> SharedSequence<DriverSharingStrategy, Void> in
                guard !activityIndicator else { return Driver.empty() }
                return nextUri ? Driver.just() : Driver.empty()
            }
        
        let tokoCashHistory = Driver.merge(loadData, nextPage)
            .withLatestFrom(Driver.combineLatest(nextUri.asDriver(), typea.asDriver(), page.asDriver(), startDate.asDriver(), endDate.asDriver()))
            .flatMapLatest { (_, type, page, startDate, endDate) -> SharedSequence<DriverSharingStrategy, TokoCashHistoryResponse> in
                TokoCashUseCase.getWalletHistory(historyType: type, perPage: 6, page: page, startDate: startDate, endDate: endDate)
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: { response in
                items.value = items.value + (response.data?.items ?? [TokoCashHistoryItems]())
                guard response.data?.nextUri ?? false else { nextUri.value = false; return }
                nextUri.value = response.data?.nextUri ?? false
                page.value = page.value + 1
            })
        
        let headers = tokoCashHistory.map { tokoCashResponse -> [TokoCashHistoryHeader] in
            return tokoCashResponse.data?.header ?? [TokoCashHistoryHeader]()
        }
        
        let showHeader = headers.map { headers -> Bool in
            return headers.count == 0
        }.startWith(true)
        
        let visibleHeaders = input.filter
            .withLatestFrom(headers) { (indexPath, headers) -> [TokoCashHistoryHeader] in
                for i in 0..<headers.count {
                    let item = headers[i]
                    if i == indexPath.row + 1 {
                        item.selected = !(item.selected ?? true)
                    } else {
                        item.selected = false
                    }
                }
                guard headers.first(where: { (header) -> Bool in header.selected ?? false }) == nil else {
                    return headers
                }
                return headers.map { header in
                    guard let type = header.type else { return header }
                    if type == "all" { header.selected = true }
                    return header
                }
            }
        
        let selectedType = Driver.merge(headers, visibleHeaders).map { $0.filter({ (header) -> Bool in
            header.selected ?? false
        }).first?.type }.do(onNext: { type in
            typea.value = type ?? "all"
        })
        
        let headersViewModel = Driver.merge(headers, visibleHeaders)
            .map { $0.filter({ (header) -> Bool in
                header.type == "all" ? false : true
            }).map { TokoCashFilterViewModel(with: $0) } }
        
        let isEmptyState = Driver.merge(activityIndicator.asDriver().flatMapLatest { isActive -> SharedSequence<DriverSharingStrategy, Bool> in
            isActive ? Driver.of(false) : Driver.empty()
        }, items.asDriver().map { (items) -> Bool in
            return items.isEmpty
        }).startWith(false)
        
        let emptyState = selectedType.map { type -> String in
            return type ?? "all"
        }
        
        let itemsViewModel = items.asDriver().map { $0.map { TokoCashHistoryListItemViewModel(with: $0) } }
        
        let selectedItem = input.selection
            .withLatestFrom(itemsViewModel) { (indexPath, itemsViewModel) -> TokoCashHistoryItems in
                return itemsViewModel[indexPath.row].historyItem
            }.do(onNext: navigator.toHistoryDetail)
        
        return Output(fetching: activityIndicator.asDriver(),
                      tokoCashHistory: tokoCashHistory,
                      showPendingTransaction: showPendingTransaction,
                      pendingTransaction: pendingTransactionTap,
                      dateString: dateString,
                      dateFilter: dateFilter,
                      headers: headersViewModel,
                      showHeader: showHeader,
                      items: itemsViewModel,
                      isEmptyState: isEmptyState,
                      emptyState: emptyState,
                      selectedItem: selectedItem,
                      page: page.asDriver())
    }
}
