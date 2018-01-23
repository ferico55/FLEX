//
//  TokoCashWalletHistoryListViewModel.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TokoCashHistoryListViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let pullTrigger: Driver<Void>
        let pendingTransactionTrigger: Driver<Void>
        let isDateRange: Driver<Bool>
        let dateRange: Driver<TokoCashDateRangeItem>
        let fromDate: Driver<Date>
        let toDate: Driver<Date>
        let dateFilterTrigger: Driver<Void>
        let filter: Driver<IndexPath>
        let selection: Driver<IndexPath>
        let nextPageTrigger: Driver<Void>
    }
    
    struct Output {
        let fetching: Driver<Bool>
        let tokoCashHistory: Driver<TokoCashHistoryResponse>
        let showPendingTransaction: Driver<Bool>
        let pendingTransaction: Driver<[TokoCashHistoryItems]>
        let dateString: Driver<String>
        let dateFilter: Driver<Void>
        let headers: Driver<[TokoCashFilterViewModel]>
        let showHeader: Driver<Bool>
        let items: Driver<[TokoCashHistoryListItemViewModel]>
        let isEmptyState: Driver<Bool>
        let emptyState: Driver<String>
        let selectedItem: Driver<TokoCashHistoryItems>
        let page: Driver<Int>
        let filterItems: Driver<TokoCashHistoryResponse>
        let nextPage: Driver<TokoCashHistoryResponse>
    }
    
    private var navigator: TokoCashHistoryListNavigator
    private var dateRange: TokoCashDateRangeItem
    private var startDate: Date
    private var endDate: Date
    
    init(navigator: TokoCashHistoryListNavigator) {
        self.navigator = navigator
        self.dateRange = TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: true)
        self.startDate = Date.aWeekAgo()
        self.endDate = Date()
    }
    
    func transform(input: Input) -> Output {
        
        let items = Variable([TokoCashHistoryItems]())
        let page = Variable(1)
        let nextUri = Variable(false)
        
        let selectedRange = Driver.merge(Driver.of(self.dateRange), input.dateRange)
        let startDate = Driver.merge(Driver.of(self.startDate), input.fromDate)
        let endDate = Driver.merge(Driver.of(self.endDate), input.toDate)
        
        let activityIndicator = ActivityIndicator()
        let errorTracker = ErrorTracker()
        
        // pending transaction
        let tokoCashPendingTrasactionResponse = input.trigger.flatMapLatest { _ in
            return TokoCashUseCase.getWalletHistory(historyType: "pending")
                .asDriverOnErrorJustComplete()
        }
        
        let pendingTransaction = tokoCashPendingTrasactionResponse.map { tokoCashPendingTrasactionResponse -> [TokoCashHistoryItems] in
            return tokoCashPendingTrasactionResponse.data?.items ?? []
        }
        
        let showPendingTransaction = pendingTransaction.map { pendingTransaction -> Bool in
            pendingTransaction.count == 0
        }.startWith(true)
        
        let pendingTransactionTap = input.pendingTransactionTrigger.withLatestFrom(pendingTransaction)
            .do(onNext: navigator.toPendingTransaction)
        
        let dateData = Driver.combineLatest(selectedRange, startDate, endDate)
        let dateFilter = input.dateFilterTrigger.withLatestFrom(dateData).do(onNext: { dateRange, startDate, endDate in
            guard let vc = UIApplication.topViewController() else { return }
            self.navigator.toDateFilter(vc as! TokoCashDateFilterDelegate, dateRange: dateRange, fromDate: startDate, toDate: endDate)
        }).mapToVoid()
        
        let dateString = Driver.combineLatest(startDate, endDate, resultSelector: { (startDate, endDate) -> String in
            guard startDate == endDate else { return "\(startDate.tpDateFormat2()) - \(endDate.tpDateFormat2())" }
            return startDate.tpDateFormat2()
        })
        
        let firstPage = Driver.merge(input.trigger.mapToVoid(), input.pullTrigger, input.filter.mapToVoid(), endDate.mapToVoid()).flatMapLatest { _ -> SharedSequence<DriverSharingStrategy, Int> in
            page.value = 1
            return page.asDriver()
        }
        
        // history
        let tokoCashHistory = Driver.merge(input.trigger, input.pullTrigger.withLatestFrom(items.asDriver()).flatMapLatest{ (items) -> SharedSequence<DriverSharingStrategy, Void> in
            guard items.count == 0 else { return Driver.empty() }
            return Driver.just()
        }).withLatestFrom(Driver.combineLatest(firstPage, startDate, endDate))
            .flatMapLatest { (page, startDate, endDate) -> SharedSequence<DriverSharingStrategy, TokoCashHistoryResponse> in
                return TokoCashUseCase.getWalletHistory(historyType: "all", perPage: 6, page: page, startDate: startDate, endDate: endDate, afterId: "")
                    .trackActivity(activityIndicator)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }.do(onNext: { response in
                items.value = response.data?.items ?? []
                guard response.data?.nextUri ?? false else { nextUri.value = false; return }
                nextUri.value = response.data?.nextUri ?? false
                page.value = page.value + 1
            })
        
        let headers = tokoCashHistory.map { tokoCashResponse -> [TokoCashHistoryHeader] in
            return tokoCashResponse.data?.header ?? []
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
        }).first?.type }
        
        let filterItems = Driver.merge(input.pullTrigger, input.filter.mapToVoid(), endDate.mapToVoid())
            .withLatestFrom(Driver.combineLatest(selectedType, firstPage, startDate, endDate))
                .flatMapLatest { (type, page, startDate, endDate) -> SharedSequence<DriverSharingStrategy, TokoCashHistoryResponse> in
                    TokoCashUseCase.getWalletHistory(historyType: type ?? "", perPage: 6, page: page, startDate: startDate, endDate: endDate, afterId: "")
                        .trackActivity(activityIndicator)
                        .trackError(errorTracker)
                        .asDriverOnErrorJustComplete()
                }.do(onNext: { response in
                    items.value = response.data?.items ?? []
                    guard response.data?.nextUri ?? false else { nextUri.value = false; return }
                    nextUri.value = response.data?.nextUri ?? false
                    page.value = page.value + 1
                })
        
        let nextPage = input.nextPageTrigger
            .withLatestFrom(Driver.combineLatest(nextUri.asDriver(), selectedType, page.asDriver(), startDate, endDate))
            .filter { (nextUri, _, _, _, _) -> Bool in
                return nextUri
            }
            .flatMapLatest { (_, type, page, startDate, endDate) -> SharedSequence<DriverSharingStrategy, TokoCashHistoryResponse> in
                TokoCashUseCase.getWalletHistory(historyType: type ?? "", perPage: 6, page: page, startDate: startDate, endDate: endDate, afterId: "")
                    .asDriverOnErrorJustComplete()
            }.do(onNext: { response in
                items.value = items.value + (response.data?.items ?? [])
                guard response.data?.nextUri ?? false else { nextUri.value = false; return }
                nextUri.value = response.data?.nextUri ?? false
                page.value = page.value + 1
            })
        
        let headersViewModel = Driver.merge(headers, visibleHeaders)
            .map { $0.filter({ (header) -> Bool in
                header.type == "all" ? false : true
            }).map { TokoCashFilterViewModel(with: $0) } }
        
        let isEmptyState = items.asDriver().map { (items) -> Bool in
            return items.count == 0
        }.startWith(false)
        
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
                      page: page.asDriver(),
                      filterItems: filterItems,
                      nextPage: nextPage)
    }
}
