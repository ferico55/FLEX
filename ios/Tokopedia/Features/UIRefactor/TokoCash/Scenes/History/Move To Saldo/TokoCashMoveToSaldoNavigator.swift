//
//  TokoCashMoveToSaldoNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashMoveToSaldoNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toHistory() {
        navigationController.popViewController(animated: true)
    }
    
    func toMoveToSaldoSuccess(_ response: TokoCashMoveToSaldoResponse) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashMoveToSaldoSuccessViewConstroller.self)
        let navigator = TokoCashMoveToSaldoSuccessNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoSuccessViewModel(status: response, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toMoveToSaldoFailed() {
        let vc = storyboard.instantiateViewController(ofType: TokoCashMoveToSaldoFailedViewConstroller.self)
        let navigator = TokoCashMoveToSaldoFailedNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoFailedViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
