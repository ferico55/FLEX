//
//  TokoCashMoveToSaldoNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashMoveToSaldoNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toHistory() {
        navigationController.popViewController(animated: true)
    }
    
    public func toMoveToSaldoSuccess(_ response: TokoCashMoveToSaldoResponse) {
        let vc = TokoCashMoveToSaldoSuccessViewController()
        let navigator = TokoCashMoveToSaldoSuccessNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoSuccessViewModel(status: response, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toMoveToSaldoFailed() {
        let vc = TokoCashMoveToSaldoFailedViewController()
        let navigator = TokoCashMoveToSaldoFailedNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashMoveToSaldoFailedViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
