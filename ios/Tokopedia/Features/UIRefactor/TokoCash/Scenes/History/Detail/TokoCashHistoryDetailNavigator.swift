//
//  TokoCashHistoryDetailNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashHistoryDetailNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toHelp(_ transactionId: String) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashHelpViewController.self)
        let navigator = TokoCashHelpNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHelpViewModel(transactionId, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toMoveToSaldo(_ historyItem: TokoCashHistoryItems) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashMoveToSaldoViewController.self)
        let navigator = TokoCashMoveToSaldoNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoViewModel(historyItem: historyItem, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
