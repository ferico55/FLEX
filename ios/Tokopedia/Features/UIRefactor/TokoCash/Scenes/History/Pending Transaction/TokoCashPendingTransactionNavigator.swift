//
//  TokoCashPendingTransactionNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashPendingTransactionNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toDetailPage(_ historyItem: TokoCashHistoryItems) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashHistoryDetailViewController.self)
        let navigator = TokoCashHistoryDetailNavigator(navigationController: navigationController)
        let viewModel = TokoCashHistoryDetailViewModel(historyItem: historyItem, navigator: navigator)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
