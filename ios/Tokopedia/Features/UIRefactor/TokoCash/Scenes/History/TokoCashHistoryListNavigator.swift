//
//  TokoCashHistoryListNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashHistoryListNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toPendingTransaction(_ pendingItems: [TokoCashHistoryItems]) {
        let vc = TokoCashPendingTransactionViewController()
        let navigator = TokoCashPendingTransactionNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashPendingTransactionViewModel(pendingItems: pendingItems, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toDateFilter(dateRange: TokoCashDateRangeItem = TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: true),
                      fromDate: Date = Date(),
                      toDate: Date = Date.aWeekAgo()) -> TokoCashDateFilterViewController {
        let vc = TokoCashDateFilterViewController()
        let navigator = TokoCashDateFilterNavigator(navigationController: navigationController)
        let viewModel = TokoCashDateFilterViewModel(selectedDateRange: dateRange, fromDate: fromDate, toDate: toDate, navigator: navigator)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
        return vc
    }
    
    public func toHistoryDetail(_ historyItem: TokoCashHistoryItems) {
        let vc = TokoCashHistoryDetailViewController()
        let navigator = TokoCashHistoryDetailNavigator(navigationController: navigationController)
        let viewModel = TokoCashHistoryDetailViewModel(historyItem: historyItem, navigator: navigator)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
