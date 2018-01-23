//
//  TokoCashHistoryListNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashHistoryListNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toPendingTransaction(_ pendingItems: [TokoCashHistoryItems]) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashPendingTransactionViewController.self)
        let navigator = TokoCashPendingTransactionNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashPendingTransactionViewModel(pendingItems: pendingItems, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toDateFilter(_ delegate: TokoCashDateFilterDelegate,
                      dateRange: TokoCashDateRangeItem = TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: true),
                      fromDate: Date = Date(),
                      toDate: Date = Date.aWeekAgo()) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashDateFilterViewController.self)
        let navigator = TokoCashDateFilterNavigator(navigationController: navigationController)
        let viewModel = TokoCashDateFilterViewModel(selectedDateRange: dateRange, fromDate: fromDate, toDate: toDate, navigator: navigator)
        viewModel.delegate = delegate
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toHistoryDetail(_ historyItem: TokoCashHistoryItems) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashHistoryDetailViewController.self)
        let navigator = TokoCashHistoryDetailNavigator(navigationController: navigationController)
        let viewModel = TokoCashHistoryDetailViewModel(historyItem: historyItem, navigator: navigator)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
