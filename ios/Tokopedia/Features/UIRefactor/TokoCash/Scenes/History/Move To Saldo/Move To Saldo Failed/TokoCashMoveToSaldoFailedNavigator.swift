//
//  TokoCashMoveToSaldoFailedNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashMoveToSaldoFailedNavigator {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func backToMoveToSaldo() {
        navigationController.popViewController(animated: true)
    }
    
    func backToTokoCash() {
        for vc in navigationController.viewControllers {
            if let viewController = vc as? TokoCashViewController {
                navigationController.popToViewController(viewController, animated: true)
            }
        }
    }
}
