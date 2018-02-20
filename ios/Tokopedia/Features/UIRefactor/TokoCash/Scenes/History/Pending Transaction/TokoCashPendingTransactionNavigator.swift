//
//  TokoCashPendingTransactionNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashPendingTransactionNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toDetailPage(_ historyItem: TokoCashHistoryItems) {
        let vc = TokoCashHistoryDetailViewController()
        let navigator = TokoCashHistoryDetailNavigator(navigationController: navigationController)
        let viewModel = TokoCashHistoryDetailViewModel(historyItem: historyItem, navigator: navigator)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
