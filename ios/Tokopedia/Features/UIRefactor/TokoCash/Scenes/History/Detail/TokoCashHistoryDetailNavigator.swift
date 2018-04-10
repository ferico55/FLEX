//
//  TokoCashHistoryDetailNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashHistoryDetailNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toHelp(_ transactionId: String) {
        let vc = TokoCashHelpViewController()
        let navigator = TokoCashHelpNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHelpViewModel(transactionId, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toMoveToSaldo(_ historyItem: TokoCashHistoryItems) {
        let vc = TokoCashMoveToSaldoViewController()
        let navigator = TokoCashMoveToSaldoNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoViewModel(historyItem: historyItem, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
